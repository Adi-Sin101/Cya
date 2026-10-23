import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import '../../core/utils/local_id.dart';
import '../../domain/entities/memory.dart';
import '../../domain/services/embedding_runtime.dart';
import '../../domain/audio/audio_attachments.dart';
import '../../domain/audio/pcm_wave.dart';
import '../db/cya_database.dart';
import '../db/audio_mapping.dart';

const semanticEnabledKey = 'semantic_enabled';

/// One bounded segment at a time, after source commit. A missing model leaves
/// durable pending jobs and all ordinary capture/browsing available.
class SemanticIndex {
  SemanticIndex(this.db, this.runtime, {this.audioFiles});
  final CyaDatabase db;
  final EmbeddingRuntime runtime;
  final AudioAttachments? audioFiles;
  final _status = StreamController<String>.broadcast();
  String status = 'Semantic memory is paused.';
  Stream<String> get changes => _status.stream;
  StreamSubscription<Object?>? _jobs;
  StreamSubscription<Object?>? _preference;
  Timer? _timer;
  bool _running = false;
  bool _disposed = false;
  bool _paused = false;

  Future<void> pause() async {
    _paused = true;
    _timer?.cancel();
    try {
      await runtime.unload();
    } on Object {
      /* Originals and jobs remain durable. */
    }
  }

  void resume() {
    _paused = false;
    wake();
  }

  void _say(String message) {
    status = message;
    if (!_disposed) _status.add(message);
  }

  Future<void> start() async {
    try {
      // A single worker owns this app process. Recover interrupted native calls;
      // vectors/progress already committed stay intact and are idempotent.
      await (db.update(
        db.memoryJobs,
      )..where((j) => j.state.equals('running'))).write(
        const MemoryJobsCompanion(
          state: Value('pending'),
          retryAt: Value(null),
        ),
      );
      await (db.update(db.memoryJobs)..where(
            (j) =>
                j.modelVersion.isNull() |
                j.modelVersion.isNotValue(EmbeddingRuntime.version),
          ))
          .write(
            const MemoryJobsCompanion(
              state: Value('pending'),
              nextSegment: Value(0),
              retryAt: Value(null),
            ),
          );
      if (_disposed) return;
      _jobs = db
          .customSelect(
            'SELECT COUNT(*) AS count FROM memory_jobs',
            readsFrom: {db.memoryJobs},
          )
          .watch()
          .listen((_) => wake());
      _preference = db.preferenceDao
          .watch(semanticEnabledKey)
          .listen((_) => wake());
      wake();
    } on Object {
      _say('Could not start local indexing. Your originals are unchanged.');
    }
  }

  void wake([Duration delay = Duration.zero]) {
    if (_disposed || _paused || _running) return;
    _timer?.cancel();
    _timer = Timer(delay, _drain);
  }

  Future<void> _drain() async {
    if (_disposed || _paused || _running) return;
    _running = true;
    MemoryJobRow? job;
    var more = false;
    try {
      if (await db.preferenceDao.read(semanticEnabledKey) != 'true') {
        _say('Semantic memory is paused. Keyword search is available.');
        return;
      }
      if (!await runtime.installed()) {
        _say('Install the local model to index saved thoughts.');
        return;
      }
      final now = DateTime.now();
      job =
          await (db.select(db.memoryJobs)
                ..where(
                  (j) =>
                      j.state.isNotValue('complete') &
                      (j.retryAt.isNull() |
                          j.retryAt.isSmallerOrEqualValue(now)),
                )
                ..limit(1))
              .getSingleOrNull();
      if (job == null) {
        final waiting = await db
            .customSelect(
              "SELECT MIN(retry_at) AS retry FROM memory_jobs WHERE state != 'complete'",
            )
            .getSingle();
        final retry = waiting.readNullable<int>('retry');
        _say(
          retry == null
              ? 'Semantic memory is ready.'
              : 'Indexing will retry after a local error.',
        );
        if (retry != null) {
          final next = DateTime.fromMillisecondsSinceEpoch(retry * 1000);
          _timer = Timer(next.difference(now), _drain);
        }
        return;
      }
      final revision = await (db.select(
        db.memoryRevisions,
      )..where((r) => r.id.equals(job!.revisionId))).getSingleOrNull();
      if (revision == null) return;
      var segment = job.nextSegment;
      if (job.modelVersion != EmbeddingRuntime.version) {
        segment = 0;
        await db.transaction(() async {
          await (db.delete(
            db.memoryVectors,
          )..where((v) => v.revisionId.equals(revision.id))).go();
          await (db.update(
            db.memoryJobs,
          )..where((j) => j.revisionId.equals(revision.id))).write(
            const MemoryJobsCompanion(
              nextSegment: Value(0),
              modelVersion: Value(EmbeddingRuntime.version),
            ),
          );
        });
      }
      final memory = await (db.select(
        db.memories,
      )..where((m) => m.id.equals(revision.memoryId))).getSingleOrNull();
      if (memory == null) return;
      final isAudio = memory.kind == 'audio';
      final attachment = isAudio
          ? await (db.select(
              db.memoryAttachments,
            )..where((a) => a.memoryId.equals(memory.id))).getSingleOrNull()
          : null;
      if (isAudio && (attachment == null || audioFiles == null)) {
        throw StateError('The original audio attachment is unavailable.');
      }
      final chunks = isAudio ? <String>[] : textChunks(revision.body);
      final count = isAudio
          ? ((attachment!.byteLength - 44) / PcmWave.segmentBytes).ceil()
          : chunks.length;
      if (count <= 0) throw StateError('No original content to index.');
      if (segment >= count) segment = 0;
      await (db.update(
        db.memoryJobs,
      )..where((j) => j.revisionId.equals(revision.id))).write(
        MemoryJobsCompanion(
          state: const Value('running'),
          retryAt: Value(now.add(const Duration(minutes: 2))),
        ),
      );
      _say('Indexing saved thoughts locally…');
      final vector = isAudio
          ? await runtime.audio(
              await audioFiles!.segment(attachment!.toCapturedAudio(), segment),
            )
          : await runtime.text('title: none | text: ${chunks[segment]}');
      if (_disposed) return;
      final bytes = encodeVector(vector);
      await db.transaction(() async {
        // A user may have deleted the source while inference was in flight.
        final source = await (db.select(
          db.memoryJobs,
        )..where((j) => j.revisionId.equals(revision.id))).getSingleOrNull();
        if (source == null) return;
        await db
            .into(db.memoryVectors)
            .insertOnConflictUpdate(
              MemoryVectorRow(
                revisionId: revision.id,
                segment: segment,
                modelVersion: EmbeddingRuntime.version,
                dimensions: EmbeddingRuntime.dimensions,
                vector: bytes,
              ),
            );
        await (db.update(
          db.memoryJobs,
        )..where((j) => j.revisionId.equals(revision.id))).write(
          MemoryJobsCompanion(
            nextSegment: Value(segment + 1),
            state: Value(segment + 1 == count ? 'complete' : 'pending'),
            attempts: const Value(0),
            retryAt: const Value(null),
            lastError: const Value(null),
          ),
        );
      });
      more = true;
    } on Object {
      _say(
        'Local indexing failed. Your original thought is safe. Retry from model settings.',
      );
      if (job != null && !_disposed) {
        try {
          final attempts = job.attempts + 1;
          await (db.update(
            db.memoryJobs,
          )..where((j) => j.revisionId.equals(job!.revisionId))).write(
            MemoryJobsCompanion(
              state: const Value('failed'),
              attempts: Value(attempts),
              retryAt: Value(
                DateTime.now().add(
                  Duration(
                    seconds: min(3600, 5 * pow(2, min(attempts, 9)).toInt()),
                  ),
                ),
              ),
              lastError: const Value('embedding_failed'),
            ),
          );
          more = true;
        } on Object {
          /* Storage failure: retry only on the next explicit wake. */
        }
      }
    } finally {
      _running = false;
      if (more && !_disposed) wake(const Duration(milliseconds: 250));
    }
  }

  Future<void> rebuild() async {
    // Preserve already running work until it returns; all sources remain saved.
    if (_running) throw StateError('Wait for the current segment to finish.');
    await db.transaction(() async {
      await db.delete(db.memoryVectors).go();
      await db.delete(db.memoryJobs).go();
      for (final revision in await db.select(db.memoryRevisions).get()) {
        await db
            .into(db.memoryJobs)
            .insert(MemoryJobsCompanion.insert(revisionId: revision.id));
      }
    });
    wake();
  }

  Future<List<Memory>> search(String query, {bool archived = false}) async {
    if (query.trim().isEmpty) return [];
    if (query.runes.length > 1000) {
      throw ArgumentError('Use a shorter search query.');
    }
    if (await db.preferenceDao.read(semanticEnabledKey) != 'true' ||
        !await runtime.installed()) {
      throw StateError(
        'Semantic memory is paused or its local model is missing.',
      );
    }
    final vector = await runtime.text('task: search result | query: $query');
    return _rank(vector, archived: archived);
  }

  Future<List<Memory>> _rank(
    List<double> query, {
    String? exclude,
    bool archived = false,
  }) async {
    if (query.length != EmbeddingRuntime.dimensions ||
        query.any((v) => !v.isFinite)) {
      throw StateError('Invalid query vector.');
    }
    final rows = await db
        .customSelect(
          '''
      SELECT m.id, r.id AS revision_id, v.vector, v.segment
      FROM memory_vectors v JOIN memory_revisions r ON r.id=v.revision_id
      JOIN memories m ON m.id=r.memory_id
      WHERE m.archived_at IS ${archived ? 'NOT NULL' : 'NULL'} AND v.model_version=? AND v.dimensions=?
      AND r.revision=(SELECT MAX(r2.revision) FROM memory_revisions r2 WHERE r2.memory_id=m.id)
    ''',
          variables: [
            Variable.withString(EmbeddingRuntime.version),
            Variable.withInt(EmbeddingRuntime.dimensions),
          ],
        )
        .get();
    final scores = <String, ({String revision, double score, int segment})>{};
    for (final row in rows) {
      final id = row.read<String>('id');
      if (id == exclude) continue;
      final data = row.read<Uint8List>('vector');
      if (data.length != EmbeddingRuntime.dimensions * 4) continue;
      final bytes = ByteData.sublistView(data);
      var score = 0.0;
      for (var i = 0; i < query.length; i++) {
        score += query[i] * bytes.getFloat32(i * 4, Endian.little);
      }
      if (!score.isFinite || (scores[id]?.score ?? -2) >= score) continue;
      scores[id] = (
        score: score,
        revision: row.read<String>('revision_id'),
        segment: row.read<int>('segment'),
      );
    }
    final ranked = scores.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    final ids = ranked.take(30).map((r) => r.revision).toList();
    if (ids.isEmpty) return [];
    // Fetch original text only for the bounded result set, not once per segment.
    final content = await db.customSelect('''
      SELECT m.id, m.kind, m.captured_at, m.archived_at, r.body, r.id AS revision_id, r.revision
      FROM memory_revisions r JOIN memories m ON m.id=r.memory_id
      WHERE r.id IN (${List.filled(ids.length, '?').join(',')})
    ''', variables: ids.map(Variable.withString).toList()).get();
    final byRevision = {
      for (final row in content)
        row.read<String>('revision_id'): Memory(
          id: row.read<String>('id'),
          text: row.read<String>('body'),
          revisionId: row.read<String>('revision_id'),
          revision: row.read<int>('revision'),
          capturedAt: DateTime.fromMillisecondsSinceEpoch(
            row.read<int>('captured_at') * 1000,
          ),
          archived: row.readNullable<int>('archived_at') != null,
          kind: row.read<String>('kind'),
          matchingSegment: scores[row.read<String>('id')]?.segment,
        ),
    };
    return [
      for (final id in ids)
        if (byRevision[id] != null) byRevision[id]!,
    ];
  }

  Future<List<Memory>> related(Memory source) async {
    final rows =
        await (db.select(db.memoryVectors)
              ..where(
                (v) =>
                    v.revisionId.equals(source.revisionId) &
                    v.modelVersion.equals(EmbeddingRuntime.version),
              )
              ..orderBy([(v) => OrderingTerm.asc(v.segment)])
              ..limit(1))
            .get();
    if (rows.isEmpty) return [];
    if (rows.single.dimensions != EmbeddingRuntime.dimensions ||
        rows.single.vector.length != EmbeddingRuntime.dimensions * 4) {
      return [];
    }
    final data = ByteData.sublistView(rows.single.vector);
    final reviewed = await (db.select(
      db.memoryLinks,
    )..where((l) => l.fromRevision.equals(source.revisionId))).get();
    final targets = reviewed.map((l) => l.toRevision).toSet();
    return (await _rank(
      List.generate(
        EmbeddingRuntime.dimensions,
        (i) => data.getFloat32(i * 4, Endian.little),
      ),
      exclude: source.id,
    )).where((m) => !targets.contains(m.revisionId)).take(5).toList();
  }

  Future<void> reviewRelated(
    Memory source,
    Memory target, {
    required bool accepted,
  }) => db.transaction(() async {
    if (source.id == target.id) {
      throw ArgumentError('A memory cannot link to itself.');
    }
    final old =
        await (db.select(db.memoryLinks)..where(
              (l) =>
                  l.fromRevision.equals(source.revisionId) &
                  l.toRevision.equals(target.revisionId) &
                  l.kind.equals('related'),
            ))
            .getSingleOrNull();
    final id = old?.id ?? newLocalId();
    final now = DateTime.now();
    final state = accepted ? 'accepted' : 'dismissed';
    await db
        .into(db.memoryLinks)
        .insertOnConflictUpdate(
          MemoryLinkRow(
            id: id,
            fromRevision: source.revisionId,
            toRevision: target.revisionId,
            kind: 'related',
            provenance: old?.provenance ?? 'model',
            state: state,
            createdAt: old?.createdAt ?? now,
          ),
        );
    await db
        .into(db.memoryEvents)
        .insert(
          MemoryEventsCompanion.insert(
            memoryId: source.id,
            type: 'link_$state',
            occurredAt: now,
            revisionId: Value(source.revisionId),
            metadata: Value(
              jsonEncode({
                'linkId': id,
                'targetRevision': target.revisionId,
                'modelVersion': EmbeddingRuntime.version,
              }),
            ),
          ),
        );
  });

  static List<String> textChunks(String source) {
    final runes = source.runes.toList();
    return [
      for (var start = 0; start < runes.length; start += 1000)
        String.fromCharCodes(
          runes.sublist(start, min(start + 1000, runes.length)),
        ),
    ];
  }

  static Uint8List encodeVector(List<double> vector) {
    if (vector.length != EmbeddingRuntime.dimensions ||
        vector.any((v) => !v.isFinite)) {
      throw StateError('Invalid embedding.');
    }
    final norm = sqrt(vector.fold<double>(0, (sum, v) => sum + v * v));
    if (!norm.isFinite || norm < 0.000001) {
      throw StateError('Invalid embedding norm.');
    }
    final bytes = ByteData(vector.length * 4);
    for (var i = 0; i < vector.length; i++) {
      bytes.setFloat32(i * 4, vector[i] / norm, Endian.little);
    }
    return bytes.buffer.asUint8List();
  }

  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    // Cancel both subscriptions synchronously before awaiting either. The store
    // may be closing in the same provider-disposal turn.
    final jobs = _jobs?.cancel();
    final preference = _preference?.cancel();
    await Future.wait<void>([?jobs, ?preference]);
    await _status.close();
  }
}
