import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../../core/utils/local_id.dart';
import '../../domain/audio/audio_attachments.dart';
import '../../domain/audio/captured_audio.dart';
import '../../domain/enums/intention_event_type.dart';
import '../../domain/enums/intention_status.dart';
import '../db/cya_database.dart';
import '../db/audio_mapping.dart';
import 'routine_backup.dart';

/// A validated snapshot, before any source rows or originals are changed.
class BackupImport {
  BackupImport._(
    this.fingerprint,
    this.intentions,
    this.events,
    this.memories,
    this.revisions,
    this.memoryEvents,
    this.links,
    this.attachments,
    this.focusSessions,
    this.focusEvents,
    this.collections,
    this.collectionEvents,
    this.assignments,
    this.routineData,
  );
  final String fingerprint;
  final List<IntentionRow> intentions;
  final List<IntentionEventRow> events;
  final List<MemoryRow> memories;
  final List<MemoryRevisionRow> revisions;
  final List<MemoryEventRow> memoryEvents;
  final List<MemoryLinkRow> links;
  final List<MemoryAttachmentRow> attachments;
  final List<FocusSessionRow> focusSessions;
  final List<FocusEventRow> focusEvents;
  final List<MemoryCollectionRow> collections;
  final List<CollectionEventRow> collectionEvents;
  final List<MemoryAssignmentRow> assignments;
  final RoutineBackup routineData;

  static BackupImport parse(String manifest, {List<String> files = const []}) {
    if (utf8.encode(manifest).length > 10 * 1024 * 1024) {
      throw const FormatException('Backup manifest is too large.');
    }
    final data = jsonDecode(manifest) as Map<String, dynamic>;
    final version = data['formatVersion'];
    if (data['format'] != 'cya.export' ||
        version is! int ||
        version < 1 ||
        version > 8) {
      throw const FormatException('Unsupported backup version.');
    }
    List<T> rows<T>(String key, T Function(Map<String, dynamic>) decode) {
      final raw = data[key] ?? const [];
      if (raw is! List ||
          raw.length > 100000 ||
          ((data['counts'] as Map)[key] ?? 0) != raw.length) {
        throw const FormatException('Invalid backup record counts.');
      }
      return [
        for (final value in raw)
          decode(Map<String, dynamic>.from(value as Map)),
      ];
    }

    Map<String, dynamic> dates(Map<String, dynamic> row, List<String> fields) =>
        {
          ...row,
          for (final key in fields)
            key: row[key] == null
                ? null
                : DateTime.parse(row[key] as String).millisecondsSinceEpoch,
        };
    final intentions = rows(
      'intentions',
      (r) => IntentionRow.fromJson(
        dates(r, [
          'capturedAt',
          'reminderAt',
          'extractedDeadline',
          'updatedAt',
        ]),
      ),
    );
    final events = rows(
      'events',
      (r) => IntentionEventRow.fromJson(dates(r, ['occurredAt'])),
    );
    final memories = rows('memories', MemoryRow.fromJson);
    final revisions = rows('memoryRevisions', MemoryRevisionRow.fromJson);
    final memoryEvents = rows('memoryEvents', MemoryEventRow.fromJson);
    final links = rows('memoryLinks', MemoryLinkRow.fromJson);
    final attachments = rows('memoryAttachments', MemoryAttachmentRow.fromJson);
    final focusSessions = rows('focusSessions', FocusSessionRow.fromJson);
    final focusEvents = rows('focusEvents', FocusEventRow.fromJson);
    final collections = rows('collections', MemoryCollectionRow.fromJson);
    final collectionEvents = rows(
      'collectionEvents',
      CollectionEventRow.fromJson,
    );
    final assignments = rows('memoryAssignments', MemoryAssignmentRow.fromJson);
    events.sort((a, b) => a.id.compareTo(b.id));
    memoryEvents.sort((a, b) => a.id.compareTo(b.id));
    focusEvents.sort((a, b) => a.id.compareTo(b.id));
    collectionEvents.sort((a, b) => a.id.compareTo(b.id));
    void require(bool condition) {
      if (!condition) {
        throw const FormatException(
          'Backup records or references are inconsistent.',
        );
      }
    }

    Set<T> ids<T>(Iterable<T> input) {
      final list = input.toList();
      final set = list.toSet();
      require(list.length == set.length);
      return set;
    }

    final promiseIds = ids(intentions.map((r) => r.id));
    final focusIds = ids(focusSessions.map((s) => s.id));
    ids(focusEvents.map((e) => e.id));
    require(
      focusSessions.every(
        (s) =>
            s.id.isNotEmpty &&
            s.priority.trim().isNotEmpty &&
            s.priority.length <= 500 &&
            (s.endedAt == null || !s.endedAt!.isBefore(s.startedAt)),
      ),
    );
    require(
      focusEvents.every(
        (e) =>
            focusIds.contains(e.sessionId) &&
            const {
              'started',
              'ended',
              'import_ended',
              'legacy_observed',
              'timer_started',
              'timer_paused',
              'timer_resumed',
              'timer_stopped',
            }.contains(e.type),
      ),
    );
    final startedFocus = focusEvents
        .where((e) => e.type == 'started' || e.type == 'legacy_observed')
        .map((e) => e.sessionId)
        .toSet();
    require(startedFocus.containsAll(focusIds));
    ids(events.map((r) => r.id));
    final memoryIds = ids(memories.map((r) => r.id));
    final collectionIds = ids(collections.map((c) => c.id));
    ids(collectionEvents.map((e) => e.id));
    ids(assignments.map((a) => a.id));
    final collectionsById = {for (final c in collections) c.id: c};
    int depth(MemoryCollectionRow collection) {
      final visited = <String>{collection.id};
      var parent = collection.parentId;
      while (parent != null) {
        require(visited.add(parent) && visited.length <= 32);
        final ancestor = collectionsById[parent];
        require(ancestor != null && ancestor.kind == 'project');
        parent = ancestor!.parentId;
      }
      return visited.length;
    }

    for (final c in collections) {
      require(
        c.id.isNotEmpty &&
            c.title.trim().isNotEmpty &&
            c.title.length <= 160 &&
            const {'topic', 'project'}.contains(c.kind),
      );
      depth(c);
    }
    collections.sort((a, b) => depth(a).compareTo(depth(b)));
    require(
      collectionEvents.every(
        (e) =>
            collectionIds.contains(e.collectionId) &&
            const {'created', 'updated'}.contains(e.type),
      ),
    );
    require(
      collectionEvents
          .where((e) => e.type == 'created')
          .map((e) => e.collectionId)
          .toSet()
          .containsAll(collectionIds),
    );
    final revisionIds = ids(revisions.map((r) => r.id));
    require(
      assignments.every(
        (a) =>
            revisionIds.contains(a.revisionId) &&
            a.context.length <= 100000 &&
            ((a.kind == 'collection' &&
                    a.intentionId == null &&
                    collectionIds.contains(a.collectionId)) ||
                (a.kind == 'intention' &&
                    a.collectionId == null &&
                    promiseIds.contains(a.intentionId))),
      ),
    );
    ids(
      assignments
          .where((a) => a.collectionId != null)
          .map((a) => '${a.revisionId}:${a.collectionId}'),
    );
    ids(
      assignments
          .where((a) => a.intentionId != null)
          .map((a) => '${a.revisionId}:${a.intentionId}'),
    );
    ids(memoryEvents.map((r) => r.id));
    ids(links.map((r) => r.id));
    ids(attachments.map((r) => r.id));
    require(
      intentions.every(
        (r) =>
            r.id > 0 &&
            r.rawContent.length <= 100000 &&
            r.sourceApp.isNotEmpty &&
            r.snoozeCount >= 0 &&
            IntentionStatus.values.any((s) => s.wire == r.status),
      ),
    );
    require(
      events.every(
        (r) =>
            promiseIds.contains(r.intentionId) &&
            IntentionEventType.tryFromWire(r.type) != null,
      ),
    );
    final capturedPromises = events
        .where((e) => e.type == 'captured')
        .map((e) => e.intentionId)
        .toSet();
    require(capturedPromises.containsAll(promiseIds));
    require(
      memories.every(
        (m) => (m.kind == 'text' || m.kind == 'audio') && m.id.isNotEmpty,
      ),
    );
    require(
      revisions.every(
        (r) =>
            memoryIds.contains(r.memoryId) &&
            r.revision > 0 &&
            r.body.length <= 100000,
      ),
    );
    ids(revisions.map((r) => '${r.memoryId}:${r.revision}'));
    final histories = <String, List<MemoryRevisionRow>>{};
    for (final r in revisions) {
      histories.putIfAbsent(r.memoryId, () => []).add(r);
    }
    final capturedMemories = memoryEvents
        .where((e) => e.type == 'captured')
        .map((e) => e.memoryId)
        .toSet();
    for (final memory in memories) {
      final history = histories[memory.id] ?? [];
      history.sort((a, b) => a.revision.compareTo(b.revision));
      require(
        history.isNotEmpty &&
            history.first.revision == 1 &&
            history.last.revision == history.length,
      );
      require(
        memory.kind == 'audio' ||
            history.every((r) => r.body.trim().isNotEmpty),
      );
      require(capturedMemories.contains(memory.id));
    }
    final revisionsById = {for (final r in revisions) r.id: r};
    require(
      memoryEvents.every(
        (e) =>
            memoryIds.contains(e.memoryId) &&
            (e.revisionId == null ||
                revisionsById[e.revisionId]?.memoryId == e.memoryId) &&
            const {
              'captured',
              'edited',
              'archived',
              'restored',
              'link_accepted',
              'link_dismissed',
              'linked',
              'branched',
              'imported',
              'assigned',
              'unassigned',
            }.contains(e.type),
      ),
    );
    require(
      links.every(
        (l) =>
            revisionIds.contains(l.fromRevision) &&
            revisionIds.contains(l.toRevision) &&
            l.fromRevision != l.toRevision &&
            const {
              'related',
              'branch',
              'supersedes',
              'supports',
              'contradicts',
            }.contains(l.kind) &&
            const {'user', 'model'}.contains(l.provenance) &&
            const {'accepted', 'dismissed'}.contains(l.state),
      ),
    );
    ids(links.map((l) => '${l.fromRevision}:${l.toRevision}:${l.kind}'));
    ids(attachments.map((a) => a.memoryId));
    ids(attachments.map((a) => a.fileName));
    final memoryKinds = {for (final m in memories) m.id: m.kind};
    final routineData = RoutineBackup.parse(data, memoryKinds);
    for (final attachment in attachments) {
      attachment.toCapturedAudio().validate();
      require(memoryKinds[attachment.memoryId] == 'audio');
    }
    require(
      memories.where((m) => m.kind == 'audio').length == attachments.length,
    );
    require(
      files.length == files.toSet().length &&
          files.toSet().containsAll(attachments.map((a) => a.fileName)) &&
          files.length == attachments.length,
    );
    return BackupImport._(
      sha256.convert(utf8.encode(manifest)).toString(),
      intentions,
      events,
      memories,
      revisions,
      memoryEvents,
      links,
      attachments,
      focusSessions,
      focusEvents,
      collections,
      collectionEvents,
      assignments,
      routineData,
    );
  }

  /// Fresh identities prevent overwriting any live row. The supplied file-copy
  /// operation is staged/verified before a single source/event/job transaction.
  Future<void> append(
    CyaDatabase db, {
    required AudioAttachments files,
    required Future<void> Function(List<Map<String, Object?>>) copyAttachments,
  }) async {
    final marker = 'imported_backup_$fingerprint';
    if (await db.preferenceDao.read(marker) != null) {
      throw StateError('This exact backup was already imported.');
    }
    final memoryIds = {for (final m in memories) m.id: newLocalId()};
    final revisionIds = {for (final r in revisions) r.id: newLocalId()};
    final linkIds = {for (final l in links) l.id: newLocalId()};
    final audioIds = {for (final a in attachments) a.id: newLocalId()};
    final focusIds = {for (final s in focusSessions) s.id: newLocalId()};
    final collectionIds = {for (final c in collections) c.id: newLocalId()};
    final assignmentIds = {for (final a in assignments) a.id: newLocalId()};
    final copied = <CapturedAudio>[];
    var committed = false;
    try {
      await copyAttachments([
        for (final a in attachments) {...a.toJson(), 'newId': audioIds[a.id]},
      ]);
      for (final a in attachments) {
        final id = audioIds[a.id]!;
        final audio = CapturedAudio(
          id: id,
          fileName: '$id.wav',
          sha256: a.sha256,
          byteLength: a.byteLength,
          durationMillis: a.durationMillis,
          capturedAt: a.capturedAt,
        );
        copied.add(audio);
      }
      for (final audio in copied) {
        await files.verify(audio);
      }
      await db.transaction(() async {
        if (await db.preferenceDao.read(marker) != null) {
          throw StateError('This backup was already imported.');
        }
        final promiseIds = <int, int>{};
        for (final r in intentions) {
          promiseIds[r.id] = await db
              .into(db.intentions)
              .insert(r.toCompanion(true).copyWith(id: const Value.absent()));
        }
        for (final e in events) {
          await db
              .into(db.intentionEvents)
              .insert(
                e
                    .toCompanion(true)
                    .copyWith(
                      id: const Value.absent(),
                      intentionId: Value(promiseIds[e.intentionId]!),
                    ),
              );
        }
        for (final c in collections) {
          await db
              .into(db.memoryCollections)
              .insert(
                c
                    .copyWith(
                      id: collectionIds[c.id]!,
                      parentId: Value(
                        c.parentId == null ? null : collectionIds[c.parentId],
                      ),
                    )
                    .toCompanion(true),
              );
        }
        for (final e in collectionEvents) {
          var metadata = e.metadata;
          try {
            final data = jsonDecode(metadata) as Map<String, dynamic>;
            for (final key in ['parentId', 'previousParent']) {
              if (collectionIds.containsKey(data[key])) {
                data[key] = collectionIds[data[key]];
              }
            }
            metadata = jsonEncode(data);
          } on Object {
            /* Retain original historical metadata. */
          }
          await db
              .into(db.collectionEvents)
              .insert(
                e
                    .toCompanion(true)
                    .copyWith(
                      id: const Value.absent(),
                      collectionId: Value(collectionIds[e.collectionId]!),
                      metadata: Value(metadata),
                    ),
              );
        }
        for (final m in memories) {
          await db
              .into(db.memories)
              .insert(m.copyWith(id: memoryIds[m.id]!).toCompanion(true));
        }
        for (final r in revisions) {
          final id = revisionIds[r.id]!;
          await db
              .into(db.memoryRevisions)
              .insert(
                r
                    .copyWith(id: id, memoryId: memoryIds[r.memoryId]!)
                    .toCompanion(true),
              );
          await db
              .into(db.memoryJobs)
              .insert(MemoryJobsCompanion.insert(revisionId: id));
        }
        for (final e in memoryEvents) {
          String? metadata = e.metadata;
          if (metadata != null) {
            try {
              final map = jsonDecode(metadata) as Map<String, dynamic>;
              for (final key in ['targetRevision', 'sourceRevision']) {
                if (revisionIds.containsKey(map[key])) {
                  map[key] = revisionIds[map[key]];
                }
              }
              if (linkIds.containsKey(map['linkId'])) {
                map['linkId'] = linkIds[map['linkId']];
              }
              if (memoryIds.containsKey(map['sourceMemory'])) {
                map['sourceMemory'] = memoryIds[map['sourceMemory']];
              }
              if (assignmentIds.containsKey(map['assignmentId'])) {
                map['assignmentId'] = assignmentIds[map['assignmentId']];
              }
              if (collectionIds.containsKey(map['collectionId'])) {
                map['collectionId'] = collectionIds[map['collectionId']];
              }
              if (promiseIds.containsKey(map['intentionId'])) {
                map['intentionId'] = promiseIds[map['intentionId']];
              }
              metadata = jsonEncode(map);
            } on Object {
              /* Preserve historical opaque metadata as originally exported. */
            }
          }
          await db
              .into(db.memoryEvents)
              .insert(
                e
                    .toCompanion(true)
                    .copyWith(
                      id: const Value.absent(),
                      memoryId: Value(memoryIds[e.memoryId]!),
                      revisionId: Value(
                        e.revisionId == null ? null : revisionIds[e.revisionId],
                      ),
                      metadata: Value(metadata),
                    ),
              );
        }
        for (final l in links) {
          await db
              .into(db.memoryLinks)
              .insert(
                l
                    .copyWith(
                      id: linkIds[l.id]!,
                      fromRevision: revisionIds[l.fromRevision]!,
                      toRevision: revisionIds[l.toRevision]!,
                    )
                    .toCompanion(true),
              );
        }
        for (final a in attachments) {
          final id = audioIds[a.id]!;
          await db
              .into(db.memoryAttachments)
              .insert(
                a
                    .copyWith(
                      id: id,
                      memoryId: memoryIds[a.memoryId]!,
                      fileName: '$id.wav',
                    )
                    .toCompanion(true),
              );
        }
        final importedAt = DateTime.now();
        for (final a in assignments) {
          await db
              .into(db.memoryAssignments)
              .insert(
                a
                    .copyWith(
                      id: assignmentIds[a.id]!,
                      revisionId: revisionIds[a.revisionId]!,
                      collectionId: Value(
                        a.collectionId == null
                            ? null
                            : collectionIds[a.collectionId],
                      ),
                      intentionId: Value(
                        a.intentionId == null
                            ? null
                            : promiseIds[a.intentionId],
                      ),
                    )
                    .toCompanion(true),
              );
        }
        for (final s in focusSessions) {
          final end = importedAt.isBefore(s.startedAt)
              ? s.startedAt
              : importedAt;
          await db
              .into(db.focusSessions)
              .insert(
                s
                    .copyWith(
                      id: focusIds[s.id]!,
                      endedAt: Value(s.endedAt ?? end),
                    )
                    .toCompanion(true),
              );
        }
        for (final e in focusEvents) {
          await db
              .into(db.focusEvents)
              .insert(
                e
                    .toCompanion(true)
                    .copyWith(
                      id: const Value.absent(),
                      sessionId: Value(focusIds[e.sessionId]!),
                    ),
              );
        }
        for (final s in focusSessions.where((s) => s.endedAt == null)) {
          await db
              .into(db.focusEvents)
              .insert(
                FocusEventsCompanion.insert(
                  sessionId: focusIds[s.id]!,
                  type: 'import_ended',
                  occurredAt: importedAt.isBefore(s.startedAt)
                      ? s.startedAt
                      : importedAt,
                ),
              );
        }
        await routineData.append(db, memoryIds);
        await db.preferenceDao.write(marker, importedAt.toIso8601String());
      });
      committed = true;
    } finally {
      if (!committed) {
        for (final audio in copied) {
          await files.delete(audio.fileName);
        }
      }
    }
  }
}
