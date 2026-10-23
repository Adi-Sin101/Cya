import 'dart:convert';
import 'dart:io';

import 'package:cya/core/di/providers.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/drift_memory_repository.dart';
import 'package:cya/data/repositories/memory_connections.dart';
import 'package:cya/data/services/backup_import.dart';
import 'package:cya/data/services/local_audio_files.dart';
import 'package:cya/domain/services/data_export.dart';
import 'package:cya/presentation/providers/memory_providers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'native_contract_test.dart'
    show nativeMemoryStatements, nativeV2CreateStatements;

void main() {
  late CyaDatabase db;
  late DriftMemoryRepository memories;
  late MemoryConnections links;
  final at = DateTime(2026, 10, 16);
  setUp(() {
    db = CyaDatabase.memory();
    memories = DriftMemoryRepository(db);
    links = MemoryConnections(db);
  });
  tearDown(() => db.close());
  test(
    'branch preserves source bytes and exact historical endpoint after an edit',
    () async {
      final id = await memories.captureText('Original source', at);
      final original = (await memories.history(id).first).single;
      final before = (await db.select(db.memories).get()).single;
      final branchId = await links.branch(
        original.revisionId,
        'Separate exploration',
        at,
        selectionStart: 0,
        selectionEnd: 8,
      );
      expect(
        (await db.select(db.memories).get()).firstWhere((m) => m.id == id),
        before,
      );
      expect((await memories.history(id).first).single.text, 'Original source');
      final event = (await db.select(db.memoryEvents).get()).singleWhere(
        (e) => e.type == 'branched',
      );
      expect(jsonDecode(event.metadata!)['quote'], 'Original');
      expect((await db.select(db.memoryJobs).get()), hasLength(2));
      await memories.edit(id, 'Changed view', at, expectedRevision: 1);
      final edge = (await db.select(db.memoryLinks).get()).single;
      expect(edge.toRevision, original.revisionId);
      expect(edge.kind, 'branch');
      expect(edge.provenance, 'user');
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final incoming = await container.read(
        linkedMemoriesProvider(original).future,
      );
      expect(incoming.single.id, branchId);
      expect(incoming.single.connectionOrigin, 'user');
      expect(incoming.single.connectionKind, 'branch');
    },
  );
  test('failed branch event rolls back new source, link and index job', () async {
    final id = await memories.captureText('Keep unchanged', at);
    final source = (await memories.history(id).first).single;
    await db.customStatement(
      "CREATE TRIGGER reject_branch BEFORE INSERT ON memory_events WHEN NEW.type='branched' BEGIN SELECT RAISE(ABORT,'fixture'); END",
    );
    await expectLater(
      links.branch(source.revisionId, 'New exploration', at),
      throwsA(anything),
    );
    expect(await db.select(db.memories).get(), hasLength(1));
    expect(await db.select(db.memoryRevisions).get(), hasLength(1));
    expect(await db.select(db.memoryEvents).get(), hasLength(1));
    expect(await db.select(db.memoryJobs).get(), hasLength(1));
    expect(await db.select(db.memoryLinks).get(), isEmpty);
  });
  test(
    'manual acceptance retains an existing model origin and review history',
    () async {
      final first = await memories.captureText('Old idea', at),
          second = await memories.captureText('New idea', at);
      final a = (await memories.history(first).first).single.revisionId,
          b = (await memories.history(second).first).single.revisionId;
      await db
          .into(db.memoryLinks)
          .insert(
            MemoryLinkRow(
              id: 'reviewed',
              fromRevision: a,
              toRevision: b,
              kind: 'related',
              provenance: 'model',
              state: 'dismissed',
              createdAt: at,
            ),
          );
      await links.link(a, b, 'related', at);
      final edge = (await db.select(db.memoryLinks).get()).single;
      expect(edge.provenance, 'model');
      expect(edge.state, 'accepted');
      expect(edge.id, 'reviewed');
      await links.link(a, b, 'related', at);
      expect(await db.select(db.memoryLinks).get(), hasLength(1));
      expect(
        (await db.select(db.memoryEvents).get()).where(
          (e) => e.type == 'linked',
        ),
        hasLength(1),
      );
    },
  );
  test(
    'promise links reuse existing task and preserve captured link context',
    () async {
      final id = await memories.captureText('Supporting thought', at);
      final source = (await memories.history(id).first).single;
      await db
          .into(db.intentions)
          .insert(
            IntentionsCompanion.insert(
              id: const Value(42),
              sourceApp: 'Cya!',
              rawContent: 'Existing promise',
              capturedAt: at,
              updatedAt: at,
            ),
          );
      await db
          .into(db.intentionEvents)
          .insert(
            IntentionEventsCompanion.insert(
              intentionId: 42,
              type: 'captured',
              occurredAt: at,
            ),
          );
      final assignment = await links.assign(
        source.revisionId,
        at,
        intentionId: 42,
      );
      expect(
        await links.assign(source.revisionId, at, intentionId: 42),
        assignment,
      );
      expect(await db.select(db.intentions).get(), hasLength(1));
      expect(await db.select(db.intentionEvents).get(), hasLength(1));
      expect(
        (await db.select(db.memoryAssignments).get()).single.context,
        'Existing promise',
      );
      await links.unassign(assignment, at);
      expect(await db.select(db.memoryAssignments).get(), isEmpty);
      expect(await db.select(db.intentions).get(), hasLength(1));
      expect((await db.select(db.memoryEvents).get()).last.type, 'unassigned');
    },
  );
  test(
    'organization rejects cycles, preserves link labels and never deletes memories',
    () async {
      final project = await links.collection('Research', 'project', at);
      final topic = await links.collection(
        'Reading',
        'topic',
        at,
        parentId: project,
      );
      await expectLater(
        links.collection(
          'Research',
          'project',
          at,
          id: project,
          parentId: project,
        ),
        throwsArgumentError,
      );
      await expectLater(
        links.collection(
          'Research',
          'project',
          at,
          id: project,
          parentId: topic,
        ),
        throwsArgumentError,
      );
      final id = await memories.captureText('Read a source', at),
          source = (await memories.history(id).first).single;
      await links.assign(source.revisionId, at, collectionId: topic);
      await links.collection(
        'New reading label',
        'topic',
        at,
        id: topic,
        parentId: project,
      );
      expect(
        (await db.select(db.memoryAssignments).get()).single.context,
        'Reading',
      );
      expect(
        (await links.inCollection(topic).first).single.revisionId,
        source.revisionId,
      );
      await links.deleteCollection(project);
      expect(
        (await db.select(db.memoryCollections).get()).single.parentId,
        isNull,
      );
      await links.deleteCollection(topic);
      expect(await db.select(db.memories).get(), hasLength(1));
      expect(await db.select(db.memoryAssignments).get(), isEmpty);
      expect(
        (await db.select(db.memoryEvents).get()).any(
          (e) => e.type == 'assigned',
        ),
        isTrue,
      );
    },
  );
  test(
    'organization edit and event reject atomically; SQL enforces assignment target XOR',
    () async {
      final project = await links.collection('Original label', 'project', at);
      await db.customStatement(
        "CREATE TRIGGER reject_collection BEFORE INSERT ON collection_events BEGIN SELECT RAISE(ABORT,'fixture'); END",
      );
      await expectLater(
        links.collection('New label', 'project', at, id: project),
        throwsA(anything),
      );
      expect(
        (await db.select(db.memoryCollections).get()).single.title,
        'Original label',
      );
      final id = await memories.captureText('Thought', at),
          revision = (await memories.history(id).first).single.revisionId;
      await expectLater(
        db
            .into(db.memoryAssignments)
            .insert(
              MemoryAssignmentRow(
                id: 'invalid',
                revisionId: revision,
                kind: 'collection',
                context: 'invalid',
                createdAt: at,
              ),
            ),
        throwsA(anything),
      );
    },
  );
  test(
    'portable organization and branch links restore with remapped identities and history',
    () async {
      final project = await links.collection('Project', 'project', at),
          topic = await links.collection('Topic', 'topic', at);
      await links.collection(
        'Topic',
        'topic',
        at,
        id: topic,
        parentId: project,
      );
      final id = await memories.captureText('Original source', at),
          revision = (await memories.history(id).first).single.revisionId;
      await links.branch(revision, 'Branch', at);
      await links.assign(revision, at, collectionId: topic);
      final document = DataExport.build(
        exportedAt: at,
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
        memoryLinks: [
          for (final r in await db.select(db.memoryLinks).get()) r.toJson(),
        ],
        collections: [
          for (final r in await db.select(db.memoryCollections).get())
            r.toJson(),
        ],
        collectionEvents: [
          for (final r in await db.select(db.collectionEvents).get())
            r.toJson(),
        ],
        memoryAssignments: [
          for (final r in await db.select(db.memoryAssignments).get())
            r.toJson(),
        ],
      );
      final backup = BackupImport.parse(jsonEncode(document));
      final target = CyaDatabase.memory(),
          root = await Directory.systemTemp.createTemp('cya-link-import-');
      try {
        await backup.append(
          target,
          files: LocalAudioFiles(directory: () async => root),
          copyAttachments: (_) async {},
        );
        final restored = await target.select(target.memoryCollections).get();
        expect(restored.map((c) => c.title), containsAll(['Project', 'Topic']));
        expect(
          restored.singleWhere((c) => c.title == 'Topic').parentId,
          restored.singleWhere((c) => c.title == 'Project').id,
        );
        expect(
          (await target.select(target.memoryAssignments).get())
              .single
              .collectionId,
          isNot(topic),
        );
        expect(
          (await target.select(target.memoryLinks).get()).single.toRevision,
          isNot(revision),
        );
        final event = (await target.select(target.memoryEvents).get())
            .singleWhere((e) => e.type == 'branched');
        expect(
          jsonDecode(event.metadata!)['sourceRevision'],
          (await target.select(target.memoryLinks).get()).single.toRevision,
        );
        expect(
          await target.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      } finally {
        await target.close();
        await root.delete(recursive: true);
      }
    },
  );
  for (final nativeFirst in [false, true]) {
    test(
      'schema6 to current preserves sources and adds organization (${nativeFirst ? 'native' : 'Dart'} first)',
      () async {
        await db.close();
        final legacy = sqlite3.openInMemory();
        addTearDown(legacy.close);
        for (final sql in nativeV2CreateStatements) {
          legacy.execute(sql);
        }
        for (final sql in nativeMemoryStatements().take(10)) {
          legacy.execute(sql);
        }
        legacy.execute(
          "INSERT INTO memories(id,captured_at,updated_at) VALUES ('old',100,100)",
        );
        legacy.execute(
          "INSERT INTO memory_revisions VALUES ('original','old',1,'Unchanged',100)",
        );
        legacy.execute('PRAGMA user_version=6');
        if (nativeFirst) {
          legacy.execute('BEGIN IMMEDIATE');
          for (final sql in nativeMemoryStatements().skip(10)) {
            legacy.execute(sql);
          }
          legacy.execute('PRAGMA user_version=8');
          legacy.execute('COMMIT');
        }
        db = CyaDatabase.forTesting(
          NativeDatabase.opened(legacy, closeUnderlyingOnClose: false),
        );
        links = MemoryConnections(db);
        await links.collection('New topic', 'topic', at);
        expect(
          (await db.select(db.memoryRevisions).get()).single.body,
          'Unchanged',
        );
        expect(legacy.select('PRAGMA foreign_key_check'), isEmpty);
        expect(
          legacy.select('PRAGMA user_version').single.values.single,
          db.schemaVersion,
        );
      },
    );
  }
}
