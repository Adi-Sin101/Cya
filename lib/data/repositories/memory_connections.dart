import 'dart:convert';

import 'package:drift/drift.dart';
import '../../core/utils/local_id.dart';
import '../../domain/entities/memory.dart';
import '../db/cya_database.dart';
import 'drift_memory_repository.dart';

/// Explicit organization over original revisions and the existing promise store.
/// Never turns a similarity score into a fact or creates a second task engine.
class MemoryConnections {
  MemoryConnections(this.db);
  final CyaDatabase db;
  Future<MemoryRevisionRow> _revision(String id) async {
    final row = await (db.select(
      db.memoryRevisions,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (row == null) throw StateError('That version no longer exists.');
    return row;
  }

  Future<void> _event(
    MemoryRevisionRow source,
    String type,
    DateTime at,
    Map<String, Object?> data,
  ) => db
      .into(db.memoryEvents)
      .insert(
        MemoryEventsCompanion.insert(
          memoryId: source.memoryId,
          type: type,
          occurredAt: at,
          revisionId: Value(source.id),
          metadata: Value(jsonEncode(data)),
        ),
      );

  Future<String> link(String from, String to, String kind, DateTime at) =>
      db.transaction(() async {
        if (from == to ||
            !const {
              'related',
              'supports',
              'contradicts',
              'supersedes',
            }.contains(kind)) {
          throw ArgumentError('Choose another version and a relationship.');
        }
        final source = await _revision(from);
        await _revision(to);
        final old =
            await (db.select(db.memoryLinks)..where(
                  (l) =>
                      l.fromRevision.equals(from) &
                      l.toRevision.equals(to) &
                      l.kind.equals(kind),
                ))
                .getSingleOrNull();
        if (old?.state == 'accepted') return old!.id;
        final id = old?.id ?? newLocalId();
        final provenance = old?.provenance ?? 'user';
        await db
            .into(db.memoryLinks)
            .insertOnConflictUpdate(
              MemoryLinkRow(
                id: id,
                fromRevision: from,
                toRevision: to,
                kind: kind,
                provenance: provenance,
                state: 'accepted',
                createdAt: old?.createdAt ?? at,
              ),
            );
        await _event(source, 'linked', at, {
          'linkId': id,
          'targetRevision': to,
          'kind': kind,
          'provenance': provenance,
          'action': 'explicit_user_link',
        });
        return id;
      });

  Future<String> branch(
    String sourceRevision,
    String text,
    DateTime at, {
    int? selectionStart,
    int? selectionEnd,
  }) => db.transaction(() async {
    final source = await _revision(sourceRevision);
    String? quote;
    if (selectionStart != null || selectionEnd != null) {
      if (selectionStart == null ||
          selectionEnd == null ||
          selectionStart < 0 ||
          selectionEnd <= selectionStart ||
          selectionEnd > source.body.length ||
          selectionEnd - selectionStart > 10000) {
        throw ArgumentError('Choose a valid source section.');
      }
      quote = source.body.substring(selectionStart, selectionEnd);
    }
    // Nested transaction joins this outer source/link/event transaction. No
    // inference is started here; consumers see jobs only after durable commit.
    final id = await DriftMemoryRepository(db).captureText(text, at);
    final revision = await (db.select(
      db.memoryRevisions,
    )..where((r) => r.memoryId.equals(id))).getSingle();
    final linkId = newLocalId();
    await db
        .into(db.memoryLinks)
        .insert(
          MemoryLinkRow(
            id: linkId,
            fromRevision: revision.id,
            toRevision: source.id,
            kind: 'branch',
            provenance: 'user',
            state: 'accepted',
            createdAt: at,
          ),
        );
    await _event(revision, 'branched', at, {
      'linkId': linkId,
      'sourceRevision': source.id,
      'sourceMemory': source.memoryId,
      'quote': ?quote,
      if (quote != null) 'selectionStart': selectionStart,
      if (quote != null) 'selectionEnd': selectionEnd,
    });
    return id;
  });

  Stream<List<MemoryCollectionRow>> collections() => (db.select(
    db.memoryCollections,
  )..orderBy([(c) => OrderingTerm.asc(c.title)])).watch();
  Future<void> _parent(String? parent, String? child) async {
    final visited = <String>{?child};
    while (parent != null) {
      if (!visited.add(parent) || visited.length > 32) {
        throw ArgumentError('Project nesting would be cyclic or too deep.');
      }
      final row = await (db.select(
        db.memoryCollections,
      )..where((c) => c.id.equals(parent!))).getSingleOrNull();
      if (row == null || row.kind != 'project') {
        throw ArgumentError('Choose an existing project as the parent.');
      }
      parent = row.parentId;
    }
  }

  Future<String> collection(
    String title,
    String kind,
    DateTime at, {
    String? parentId,
    String? id,
  }) => db.transaction(() async {
    final value = title.trim();
    if (value.isEmpty ||
        value.length > 160 ||
        !const {'topic', 'project'}.contains(kind)) {
      throw ArgumentError('Choose a title and topic or project.');
    }
    final old = id == null
        ? null
        : await (db.select(
            db.memoryCollections,
          )..where((c) => c.id.equals(id))).getSingleOrNull();
    if (id != null && old == null) {
      throw StateError('This collection no longer exists.');
    }
    if (old != null && old.kind != kind) {
      throw ArgumentError('Collection type stays as originally chosen.');
    }
    await _parent(parentId, id);
    final key = id ?? newLocalId();
    await db
        .into(db.memoryCollections)
        .insertOnConflictUpdate(
          MemoryCollectionRow(
            id: key,
            title: value,
            kind: kind,
            parentId: parentId,
            createdAt: old?.createdAt ?? at,
          ),
        );
    await db
        .into(db.collectionEvents)
        .insert(
          CollectionEventsCompanion.insert(
            collectionId: key,
            type: old == null ? 'created' : 'updated',
            occurredAt: at,
            metadata: jsonEncode({
              'title': value,
              'kind': kind,
              'parentId': parentId,
              if (old != null) 'previousTitle': old.title,
              if (old != null) 'previousParent': old.parentId,
            }),
          ),
        );
    return key;
  });
  Future<void> deleteCollection(String id) => db.transaction(() async {
    // Only organization is removed; source memories and promise rows remain.
    await (db.delete(db.memoryCollections)..where((c) => c.id.equals(id))).go();
  });
  Future<String> assign(
    String revisionId,
    DateTime at, {
    String? collectionId,
    int? intentionId,
  }) => db.transaction(() async {
    if ((collectionId == null) == (intentionId == null)) {
      throw ArgumentError('Choose exactly one destination.');
    }
    final source = await _revision(revisionId);
    String context;
    if (collectionId != null) {
      context = (await (db.select(
        db.memoryCollections,
      )..where((c) => c.id.equals(collectionId))).getSingle()).title;
    } else {
      context = (await (db.select(
        db.intentions,
      )..where((i) => i.id.equals(intentionId!))).getSingle()).rawContent;
    }
    final old =
        await (db.select(db.memoryAssignments)..where(
              (a) =>
                  a.revisionId.equals(revisionId) &
                  (collectionId != null
                      ? a.collectionId.equals(collectionId)
                      : a.intentionId.equals(intentionId!)),
            ))
            .getSingleOrNull();
    if (old != null) return old.id;
    final id = newLocalId();
    final kind = collectionId == null ? 'intention' : 'collection';
    await db
        .into(db.memoryAssignments)
        .insert(
          MemoryAssignmentRow(
            id: id,
            revisionId: revisionId,
            collectionId: collectionId,
            intentionId: intentionId,
            kind: kind,
            context: context,
            createdAt: at,
          ),
        );
    await _event(source, 'assigned', at, {
      'assignmentId': id,
      'collectionId': collectionId,
      'intentionId': intentionId,
      'context': context,
      'kind': kind,
    });
    return id;
  });
  Future<void> unassign(String id, DateTime at) => db.transaction(() async {
    final row = await (db.select(
      db.memoryAssignments,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    final source = await _revision(row.revisionId);
    await (db.delete(db.memoryAssignments)..where((a) => a.id.equals(id))).go();
    await _event(source, 'unassigned', at, {
      'assignmentId': id,
      'collectionId': row.collectionId,
      'intentionId': row.intentionId,
      'context': row.context,
      'kind': row.kind,
    });
  });
  Stream<List<Memory>> inCollection(String id) => db
      .customSelect(
        '''
    SELECT m.id,m.kind,m.captured_at,m.archived_at,r.id AS revision_id,r.revision,r.body
    FROM memory_assignments a JOIN memory_revisions r ON r.id=a.revision_id
    JOIN memories m ON m.id=r.memory_id WHERE a.collection_id=? ORDER BY a.created_at DESC
  ''',
        variables: [Variable.withString(id)],
        readsFrom: {db.memoryAssignments, db.memoryRevisions, db.memories},
      )
      .watch()
      .map(
        (rows) => [
          for (final row in rows)
            Memory(
              id: row.read('id'),
              text: row.read('body'),
              revisionId: row.read('revision_id'),
              revision: row.read('revision'),
              capturedAt: DateTime.fromMillisecondsSinceEpoch(
                row.read<int>('captured_at') * 1000,
              ),
              archived: row.readNullable<int>('archived_at') != null,
              kind: row.read('kind'),
            ),
        ],
      );
}
