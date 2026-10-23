import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/drift_memory_repository.dart';
import 'package:cya/data/services/attachment_cleanup.dart';
import 'package:cya/data/services/local_audio_files.dart';
import 'package:cya/data/services/semantic_index.dart';
import 'package:cya/data/services/backup_import.dart';
import 'package:cya/domain/services/data_export.dart';
import 'package:cya/domain/audio/captured_audio.dart';
import 'package:cya/domain/audio/pcm_wave.dart';
import 'package:cya/domain/services/embedding_runtime.dart';
import 'package:flutter_test/flutter_test.dart';

class AudioWorkflowEncoder implements EmbeddingRuntime {
  final audioInputs = <Uint8List>[];
  @override
  Future<bool> installed() async => true;
  @override
  Future<bool> install() async => true;
  @override
  Future<void> unload() async {}
  @override
  Future<List<double>> text(String input) async =>
      throw StateError('No transcript path');
  @override
  Future<List<double>> audio(Uint8List wav) async {
    audioInputs.add(wav);
    return List.generate(256, (i) => i == 0 ? 1.0 : 0.0);
  }
}

void main() {
  late Directory root;
  late LocalAudioFiles files;
  late CyaDatabase db;
  late DriftMemoryRepository repo;
  late File original;
  late CapturedAudio audio;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('cya-audio-test-');
    files = LocalAudioFiles(directory: () async => root);
    db = CyaDatabase.memory();
    repo = DriftMemoryRepository(db, audioFiles: files);
    const id = '12345678-1234-4234-8234-123456789abc';
    final bytes = PcmWave.wrap(Uint8List(PcmWave.bytesPerSecond * 21));
    original = File('${root.path}/memory_audio/$id.wav');
    await original.parent.create(recursive: true);
    await original.writeAsBytes(bytes, flush: true);
    audio = CapturedAudio(
      id: id,
      fileName: '$id.wav',
      sha256: sha256.convert(bytes).toString(),
      byteLength: bytes.length,
      durationMillis: 21000,
      capturedAt: DateTime(2026, 10, 15),
    );
  });
  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });

  test(
    'audio backup restores fresh originals and rollback removes only new copies',
    () async {
      await repo.captureAudio(audio);
      final target = CyaDatabase.memory();
      addTearDown(target.close);
      final document = DataExport.build(
        exportedAt: DateTime(2026),
        intentions: [],
        events: [],
        preferences: {},
        memories: [
          for (final r in await db.select(db.memories).get()) r.toJson(),
        ],
        memoryRevisions: [
          for (final r in await db.select(db.memoryRevisions).get()) r.toJson(),
        ],
        memoryEvents: [
          for (final r in await db.select(db.memoryEvents).get()) r.toJson(),
        ],
        memoryAttachments: [
          for (final r in await db.select(db.memoryAttachments).get())
            r.toJson(),
        ],
      );
      expect(
        () => BackupImport.parse(jsonEncode(document)),
        throwsFormatException,
      );
      final backup = BackupImport.parse(
        jsonEncode(document),
        files: [audio.fileName],
      );
      Future<void> copy(List<Map<String, Object?>> rows) async {
        for (final row in rows) {
          await original.copy('${original.parent.path}/${row['newId']}.wav');
        }
      }

      await target.customStatement(
        "CREATE TRIGGER reject_import BEFORE INSERT ON memory_events BEGIN SELECT RAISE(ABORT,'fixture'); END",
      );
      await expectLater(
        backup.append(target, files: files, copyAttachments: copy),
        throwsA(anything),
      );
      expect(await original.parent.list().length, 1);
      expect(await original.exists(), isTrue);
      await target.customStatement('DROP TRIGGER reject_import');
      await backup.append(target, files: files, copyAttachments: copy);
      final restored =
          (await target.select(target.memoryAttachments).get()).single;
      expect(restored.fileName, isNot(audio.fileName));
      expect(restored.sha256, audio.sha256);
      expect(
        await File(
          '${original.parent.path}/${restored.fileName}',
        ).readAsBytes(),
        await original.readAsBytes(),
      );
      expect(
        (await target.select(target.memoryRevisions).get()).single.body,
        isEmpty,
      );
      expect(await target.select(target.memoryJobs).get(), hasLength(1));
    },
  );

  test(
    'durable original is required and retry never duplicates a memory',
    () async {
      final id = await repo.captureAudio(audio);
      expect(await repo.captureAudio(audio), id);
      expect(await db.select(db.memories).get(), hasLength(1));
      expect((await repo.watch().first).single.isAudio, isTrue);
      expect((await db.select(db.memoryRevisions).get()).single.body, isEmpty);
      expect(await db.select(db.memoryEvents).get(), hasLength(1));
      expect(await db.select(db.memoryJobs).get(), hasLength(1));
      await original.delete();
      await expectLater(repo.captureAudio(audio), throwsA(anything));
      expect(await db.select(db.memories).get(), hasLength(1));
    },
  );

  test(
    'raw audio segments index without a caption or transcript and preserve original',
    () async {
      final before = await original.readAsBytes();
      final encoder = AudioWorkflowEncoder();
      final index = SemanticIndex(db, encoder, audioFiles: files);
      addTearDown(index.dispose);
      await repo.captureAudio(audio);
      await db.preferenceDao.write(semanticEnabledKey, 'true');
      await index.start();
      final deadline = DateTime.now().add(const Duration(seconds: 8));
      while ((await db.select(db.memoryJobs).get()).single.state !=
          'complete') {
        if (DateTime.now().isAfter(deadline)) {
          fail('Audio index did not finish');
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      expect(encoder.audioInputs.map((b) => b.length), [640044, 32044]);
      expect(await db.select(db.memoryVectors).get(), hasLength(2));
      expect(await original.readAsBytes(), before);
    },
  );

  test(
    'delete transaction queues cleanup and a later retry removes original',
    () async {
      final id = await repo.captureAudio(audio);
      // Simulate an unavailable file service at deletion, as after process death.
      await DriftMemoryRepository(db).deleteMemory(id);
      expect(await db.select(db.memories).get(), isEmpty);
      expect(await db.select(db.memoryAttachments).get(), isEmpty);
      expect(await db.select(db.memoryJobs).get(), isEmpty);
      expect(await original.exists(), isTrue);
      expect(await db.select(db.attachmentCleanup).get(), hasLength(1));
      await AttachmentCleanupService(db, files).run();
      expect(await original.exists(), isFalse);
      expect(await db.select(db.attachmentCleanup).get(), isEmpty);
    },
  );

  test(
    'corrupt samples and traversal references fail before acknowledgement',
    () async {
      final bytes = await original.readAsBytes();
      bytes[100] = 1;
      await original.writeAsBytes(bytes, flush: true);
      await expectLater(repo.captureAudio(audio), throwsFormatException);
      expect(await db.select(db.memories).get(), isEmpty);
      await expectLater(files.delete('../outside.wav'), throwsFormatException);
    },
  );
}
