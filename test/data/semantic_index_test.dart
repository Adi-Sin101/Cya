import 'dart:async';

import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/drift_memory_repository.dart';
import 'package:cya/data/services/semantic_index.dart';
import 'package:cya/domain/services/embedding_runtime.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

/// Workflow doubles only; actual model correctness is tested with pinned native
/// artifacts in the diagnostic APK, never inferred from these synthetic vectors.
class WorkflowEncoder implements EmbeddingRuntime {
  bool available = true;
  bool fail = false;
  final inputs = <String>[];
  Completer<void>? gate;
  Future<void> Function()? onText;
  @override
  Future<bool> installed() async => available;
  @override
  Future<bool> install() async => available;
  @override
  Future<void> unload() async {}
  @override
  Future<List<double>> audio(Uint8List wav) => throw UnimplementedError();
  @override
  Future<List<double>> text(String input) async {
    inputs.add(input);
    await onText?.call();
    await gate?.future;
    if (fail) throw StateError('workflow fixture failure');
    final vector = List.filled(EmbeddingRuntime.dimensions, 0.0);
    vector[input.contains('book') || input.contains('reading') ? 1 : 2] = 1;
    return vector;
  }
}

void main() {
  late CyaDatabase db;
  late DriftMemoryRepository repo;
  late WorkflowEncoder encoder;
  late SemanticIndex index;
  final at = DateTime(2026, 10, 15);
  setUp(() {
    db = CyaDatabase.memory();
    repo = DriftMemoryRepository(db);
    encoder = WorkflowEncoder();
    index = SemanticIndex(db, encoder);
  });
  tearDown(() async {
    await index.dispose();
    await db.close();
  });

  Future<void> until(Future<bool> Function() condition) async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!await condition()) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Timed out waiting for workflow condition');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  Future<void> completeJobs() => until(
    () async => (await db.select(db.memoryJobs).get()).every(
      (j) => j.state == 'complete',
    ),
  );
  Future<void> enable() async {
    await db.preferenceDao.write(semanticEnabledKey, 'true');
    await index.start();
  }

  test(
    'capture commits before inference and never awaits a blocked encoder',
    () async {
      encoder.gate = Completer<void>();
      encoder.onText = () async {
        expect(await db.select(db.memories).get(), hasLength(1));
        expect(await db.select(db.memoryEvents).get(), hasLength(1));
      };
      await enable();
      await repo
          .captureText('A book thought', at)
          .timeout(const Duration(seconds: 1));
      await until(() async => encoder.inputs.isNotEmpty);
      expect(await db.select(db.memoryVectors).get(), isEmpty);
      encoder.gate!.complete();
      await completeJobs();
      final vector = (await db.select(db.memoryVectors).get()).single;
      expect(vector.vector.length, 256 * 4);
      expect(vector.modelVersion, EmbeddingRuntime.version);
    },
  );

  test(
    'disabled or missing model leaves keyword capture and durable pending jobs',
    () async {
      encoder.available = false;
      await enable();
      await repo.captureText('কাল meeting', at);
      await until(() async => index.status.contains('Install'));
      expect(encoder.inputs, isEmpty);
      expect((await db.select(db.memoryJobs).get()).single.state, 'pending');
      expect(await repo.watch(query: 'কাল').first, hasLength(1));
      await expectLater(index.search('meeting'), throwsStateError);
    },
  );

  test('delete during inference cannot recreate orphan vectors', () async {
    encoder.gate = Completer<void>();
    final id = await repo.captureText('A book', at);
    await enable();
    await until(() async => encoder.inputs.isNotEmpty);
    await repo.deleteMemory(id);
    encoder.gate!.complete();
    await until(() async => index.status == 'Semantic memory is ready.');
    expect(await db.select(db.memoryVectors).get(), isEmpty);
    expect(await db.select(db.memoryJobs).get(), isEmpty);
  });

  test('failed job preserves source and explicit rebuild retries it', () async {
    encoder.fail = true;
    await repo.captureText('My book', at);
    await enable();
    await until(
      () async =>
          (await db.select(db.memoryJobs).get()).single.state == 'failed',
    );
    expect((await repo.watch().first).single.text, 'My book');
    expect((await db.select(db.memoryJobs).get()).single.attempts, 1);
    encoder.fail = false;
    await index.rebuild();
    await completeJobs();
    expect(encoder.inputs, hasLength(2));
  });

  test(
    'text chunking preserves non-BMP Unicode and persists segment progress',
    () async {
      final original = List.filled(1001, '𓀀').join();
      expect(SemanticIndex.textChunks(original).join(), original);
      await repo.captureText(original, at);
      await enable();
      await completeJobs();
      expect(encoder.inputs, hasLength(2));
      expect((await db.select(db.memoryJobs).get()).single.nextSegment, 2);
      expect(await db.select(db.memoryVectors).get(), hasLength(2));
    },
  );

  test(
    'ranking and reviewed suggestions use version-matched derived vectors only',
    () async {
      final source = await repo.captureText('A book', at);
      final target = await repo.captureText('reading reflections', at);
      await repo.captureText('tea', at);
      await enable();
      await completeJobs();
      final results = await index.search('reading');
      expect(
        results.first.id,
        isNot((await repo.watch(query: 'tea').first).single.id),
      );
      final from = (await repo.history(source).first).first;
      final to = (await repo.history(target).first).first;
      expect((await index.related(from)).first.id, target);
      await index.reviewRelated(from, to, accepted: false);
      expect((await index.related(from)).any((m) => m.id == target), isFalse);
      final link = (await db.select(db.memoryLinks).get()).single;
      expect(link.provenance, 'model');
      expect(link.state, 'dismissed');
      expect((await repo.history(source).first).single.text, 'A book');
      expect(
        (await db.select(db.memoryEvents).get()).last.metadata,
        contains(to.revisionId),
      );
      await repo.deleteMemory(target);
      expect(await db.select(db.memoryLinks).get(), isEmpty);
      expect(
        (await db.select(db.memoryVectors).get()).every(
          (v) => v.revisionId != to.revisionId,
        ),
        isTrue,
      );
    },
  );

  test('a model/preprocessing upgrade reindexes completed old jobs', () async {
    await repo.captureText('A book', at);
    final job = (await db.select(db.memoryJobs).get()).single;
    await (db.update(
      db.memoryJobs,
    )..where((j) => j.revisionId.equals(job.revisionId))).write(
      const MemoryJobsCompanion(
        state: Value('complete'),
        modelVersion: Value('old-model'),
        nextSegment: Value(1),
      ),
    );
    await enable();
    await completeJobs();
    expect(encoder.inputs, hasLength(1));
    expect(
      (await db.select(db.memoryJobs).get()).single.modelVersion,
      EmbeddingRuntime.version,
    );
  });

  test(
    'background pause finishes one segment and resumes without losing progress',
    () async {
      encoder.gate = Completer<void>();
      await repo.captureText(List.filled(1001, 'a').join(), at);
      await enable();
      await until(() async => encoder.inputs.isNotEmpty);
      await index.pause();
      encoder.gate!.complete();
      await until(
        () async =>
            (await db.select(db.memoryJobs).get()).single.nextSegment == 1,
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(encoder.inputs, hasLength(1));
      index.resume();
      await completeJobs();
      expect(encoder.inputs, hasLength(2));
    },
  );

  test('interrupted job resumes at its next durable segment', () async {
    await repo.captureText(List.filled(1001, 'a').join(), at);
    final revision = (await db.select(db.memoryRevisions).get()).single;
    await db
        .into(db.memoryVectors)
        .insert(
          MemoryVectorRow(
            revisionId: revision.id,
            segment: 0,
            modelVersion: EmbeddingRuntime.version,
            dimensions: 256,
            vector: SemanticIndex.encodeVector([1.0, ...List.filled(255, 0.0)]),
          ),
        );
    await db
        .update(db.memoryJobs)
        .write(
          const MemoryJobsCompanion(
            state: Value('running'),
            nextSegment: Value(1),
            modelVersion: Value(EmbeddingRuntime.version),
          ),
        );
    await enable();
    await completeJobs();
    expect(encoder.inputs, hasLength(1));
    expect(encoder.inputs.single, 'title: none | text: a');
    expect(await db.select(db.memoryVectors).get(), hasLength(2));
  });
}
