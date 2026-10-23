import 'package:drift/drift.dart';

import '../../core/utils/local_id.dart';

import '../../domain/entities/memory.dart';
import '../../domain/repositories/memory_repository.dart';
import '../../domain/audio/audio_attachments.dart';
import '../../domain/audio/captured_audio.dart';
import '../db/cya_database.dart';
import '../services/attachment_cleanup.dart';

class DriftMemoryRepository implements MemoryRepository {
  DriftMemoryRepository(this.db, {this.audioFiles});
  final CyaDatabase db;
  final AudioAttachments? audioFiles;

  void _validate(String text) {
    if (text.trim().isEmpty) {
      throw ArgumentError('Write a thought before saving.');
    }
    if (text.length > 100000) {
      throw ArgumentError('A thought can contain up to 100,000 characters.');
    }
  }

  @override
  Future<String> captureText(String text, DateTime at) async {
    _validate(text);
    final id = newLocalId();
    await db.transaction(() async {
      await db
          .into(db.memories)
          .insert(
            MemoryRow(
              id: id,
              kind: 'text',
              source: 'Cya!',
              capturedAt: at,
              updatedAt: at,
            ),
          );
      await _revision(id, text, 1, 'captured', at);
    });
    return id;
  }

  Future<void> _revision(
    String id,
    String text,
    int revision,
    String event,
    DateTime at,
  ) async {
    final revisionId = newLocalId();
    await db
        .into(db.memoryRevisions)
        .insert(
          MemoryRevisionRow(
            id: revisionId,
            memoryId: id,
            revision: revision,
            body: text,
            createdAt: at,
          ),
        );
    await db
        .into(db.memoryEvents)
        .insert(
          MemoryEventsCompanion.insert(
            memoryId: id,
            type: event,
            occurredAt: at,
            revisionId: Value(revisionId),
          ),
        );
    await db
        .into(db.memoryJobs)
        .insert(MemoryJobsCompanion.insert(revisionId: revisionId));
  }

  @override
  Future<String> captureAudio(CapturedAudio audio) async {
    audio.validate();
    final store = audioFiles;
    if (store == null) throw StateError('Local audio storage is unavailable.');
    // Original finalized file and checksum verified before source acknowledgement.
    await store.verify(audio);
    return db.transaction(() async {
      final existing = await (db.select(
        db.memoryAttachments,
      )..where((a) => a.id.equals(audio.id))).getSingleOrNull();
      if (existing != null) {
        if (existing.fileName != audio.fileName ||
            existing.sha256 != audio.sha256 ||
            existing.byteLength != audio.byteLength ||
            existing.durationMillis != audio.durationMillis) {
          throw StateError(
            'This recording reference already belongs to different content.',
          );
        }
        return existing.memoryId;
      }
      final id = newLocalId();
      await db
          .into(db.memories)
          .insert(
            MemoryRow(
              id: id,
              kind: 'audio',
              source: 'Cya!',
              capturedAt: audio.capturedAt,
              updatedAt: audio.capturedAt,
            ),
          );
      await db
          .into(db.memoryAttachments)
          .insert(
            MemoryAttachmentRow(
              id: audio.id,
              memoryId: id,
              fileName: audio.fileName,
              sha256: audio.sha256,
              byteLength: audio.byteLength,
              durationMillis: audio.durationMillis,
              capturedAt: audio.capturedAt,
            ),
          );
      await _revision(id, '', 1, 'captured', audio.capturedAt);
      return id;
    });
  }

  @override
  Future<void> edit(
    String id,
    String text,
    DateTime at, {
    required int expectedRevision,
  }) async {
    await db.transaction(() async {
      final memory = await (db.select(
        db.memories,
      )..where((m) => m.id.equals(id))).getSingleOrNull();
      if (memory == null) throw StateError('This memory no longer exists.');
      if (memory.kind != 'audio') _validate(text);
      if (text.length > 100000) {
        throw ArgumentError('A caption can contain up to 100,000 characters.');
      }
      final revisions =
          await (db.select(db.memoryRevisions)
                ..where((t) => t.memoryId.equals(id))
                ..orderBy([(t) => OrderingTerm.desc(t.revision)])
                ..limit(1))
              .get();
      if (revisions.isEmpty) throw StateError('This memory no longer exists.');
      if (revisions.single.revision != expectedRevision) {
        throw StateError(
          'This memory changed. Reopen it before saving your edit.',
        );
      }
      if (revisions.single.body == text) return;
      await _revision(id, text, expectedRevision + 1, 'edited', at);
      await (db.update(db.memories)..where((t) => t.id.equals(id))).write(
        MemoriesCompanion(updatedAt: Value(at)),
      );
    });
  }

  @override
  Stream<List<Memory>> watch({String query = '', bool archived = false}) {
    // Literal substring fallback retains Bangla vowel/combining marks. No SQL
    // interpolation, wildcard syntax, model or transcript dependency.
    return db
        .customSelect(
          '''
      SELECT m.id, m.kind, m.captured_at, m.archived_at, r.id AS revision_id, r.revision, r.body
      FROM memories m JOIN memory_revisions r ON r.memory_id = m.id
      WHERE r.revision = (SELECT MAX(r2.revision) FROM memory_revisions r2 WHERE r2.memory_id = m.id)
      AND m.archived_at IS ${archived ? 'NOT NULL' : 'NULL'}
      AND instr(lower(r.body), lower(?)) > 0
      ORDER BY m.updated_at DESC, m.id DESC
    ''',
          variables: [Variable.withString(query)],
          readsFrom: {db.memories, db.memoryRevisions},
        )
        .watch()
        .map((rows) => rows.map(_memory).toList());
  }

  Memory _memory(QueryRow row) => Memory(
    id: row.read<String>('id'),
    text: row.read<String>('body'),
    revisionId: row.read<String>('revision_id'),
    revision: row.read<int>('revision'),
    capturedAt: DateTime.fromMillisecondsSinceEpoch(
      row.read<int>('captured_at') * 1000,
    ),
    archived: row.readNullable<int>('archived_at') != null,
    kind: row.read<String>('kind'),
  );

  @override
  Stream<List<Memory>> history(String id) => db
      .customSelect(
        '''
    SELECT m.id, m.kind, m.captured_at, m.archived_at, r.id AS revision_id, r.revision, r.body
    FROM memories m JOIN memory_revisions r ON r.memory_id = m.id
    WHERE m.id = ? ORDER BY r.revision DESC
  ''',
        variables: [Variable.withString(id)],
        readsFrom: {db.memories, db.memoryRevisions},
      )
      .watch()
      .map((rows) => rows.map(_memory).toList());

  @override
  Future<void> archive(String id, bool archived, DateTime at) =>
      db.transaction(() async {
        final changed =
            await (db.update(db.memories)..where((t) => t.id.equals(id))).write(
              MemoriesCompanion(
                archivedAt: Value(archived ? at : null),
                updatedAt: Value(at),
              ),
            );
        if (changed != 1) throw StateError('This memory no longer exists.');
        await db
            .into(db.memoryEvents)
            .insert(
              MemoryEventsCompanion.insert(
                memoryId: id,
                type: archived ? 'archived' : 'restored',
                occurredAt: at,
              ),
            );
      });

  @override
  Future<void> deleteMemory(String id) async {
    await db.transaction(() async {
      final attachments = await (db.select(
        db.memoryAttachments,
      )..where((a) => a.memoryId.equals(id))).get();
      for (final attachment in attachments) {
        await db
            .into(db.attachmentCleanup)
            .insertOnConflictUpdate(
              AttachmentCleanupRow(
                fileName: attachment.fileName,
                createdAt: DateTime.now(),
              ),
            );
      }
      // Cascades remove revisions/events/vectors/jobs/links, retaining cleanup.
      await (db.delete(db.memories)..where((t) => t.id.equals(id))).go();
    });
    await cleanupAttachments();
  }

  Future<void> cleanupAttachments() async {
    final store = audioFiles;
    if (store == null) return;
    await AttachmentCleanupService(db, store).run();
  }

  @override
  Future<void> rebuildIndex() => db.transaction(() async {
    await db.delete(db.memoryVectors).go();
    await db.delete(db.memoryJobs).go();
    final revisions = await db.select(db.memoryRevisions).get();
    for (final revision in revisions) {
      await db
          .into(db.memoryJobs)
          .insert(MemoryJobsCompanion.insert(revisionId: revision.id));
    }
  });
}
