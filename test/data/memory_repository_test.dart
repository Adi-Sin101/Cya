import 'dart:io';

import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/drift_memory_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'native_contract_test.dart'
    show nativeMemoryStatements, nativeV2CreateStatements;

void main() {
  late CyaDatabase db;
  late DriftMemoryRepository repo;
  final at = DateTime(2026, 10, 15, 12);
  setUp(() {
    db = CyaDatabase.memory();
    repo = DriftMemoryRepository(db);
  });
  tearDown(() => db.close());

  test(
    'save preserves original bytes and commits event/job without a promise',
    () async {
      const original = '  কাল আমার meeting আছে।\nAmi jabo.  ';
      final id = await repo.captureText(original, at);
      final memory = (await repo.watch().first).single;
      expect(memory.id, id);
      expect(memory.text, original);
      expect(await db.select(db.intentions).get(), isEmpty);
      expect((await db.select(db.memoryEvents).get()).single.type, 'captured');
      expect((await db.select(db.memoryJobs).get()).single.state, 'pending');
    },
  );

  test('failed event insert rolls back the source, revision and job', () async {
    await db.customStatement(
      "CREATE TRIGGER fail_event BEFORE INSERT ON memory_events BEGIN SELECT RAISE(ABORT, 'fixture'); END",
    );
    await expectLater(repo.captureText('Keep me', at), throwsA(anything));
    expect(await db.select(db.memories).get(), isEmpty);
    expect(await db.select(db.memoryRevisions).get(), isEmpty);
    expect(await db.select(db.memoryJobs).get(), isEmpty);
  });

  test(
    'edits preserve every revision and reject stale concurrent editors',
    () async {
      final id = await repo.captureText('Original reflection', at);
      await repo.edit(id, 'Updated belief', at, expectedRevision: 1);
      expect((await repo.history(id).first).map((r) => r.text), [
        'Updated belief',
        'Original reflection',
      ]);
      await expectLater(
        repo.edit(id, 'Stale update', at, expectedRevision: 1),
        throwsStateError,
      );
      expect((await repo.watch().first).single.text, 'Updated belief');
      expect(await db.select(db.memoryEvents).get(), hasLength(2));
    },
  );

  test(
    'literal keyword fallback distinguishes Bangla marks and supports Banglish',
    () async {
      await repo.captureText('কাল meeting korbo', at);
      await repo.captureText('কুল fruit', at);
      expect(
        (await repo.watch(query: 'কাল').first).single.text,
        'কাল meeting korbo',
      );
      expect((await repo.watch(query: 'কুল').first).single.text, 'কুল fruit');
      expect(await repo.watch(query: 'MEETING').first, hasLength(1));
      expect(await repo.watch(query: 'korbo').first, hasLength(1));
      expect(await repo.watch(query: "%' OR 1=1 --").first, isEmpty);
    },
  );

  test(
    'archive retains history; hard delete removes events and derived jobs',
    () async {
      final id = await repo.captureText('Private thought', at);
      await repo.archive(id, true, at);
      expect(await repo.watch().first, isEmpty);
      expect(await repo.watch(archived: true).first, hasLength(1));
      expect(await repo.history(id).first, hasLength(1));
      await repo.archive(id, false, at);
      expect(await repo.watch().first, hasLength(1));
      await repo.deleteMemory(id);
      expect(await db.select(db.memoryRevisions).get(), isEmpty);
      expect(await db.select(db.memoryEvents).get(), isEmpty);
      expect(await db.select(db.memoryJobs).get(), isEmpty);
    },
  );

  test(
    'rebuild queues all versions and global erase includes neutral memories',
    () async {
      final id = await repo.captureText('Old', at);
      await repo.edit(id, 'New', at, expectedRevision: 1);
      await db.customStatement(
        "UPDATE memory_jobs SET state = 'failed', attempts = 3",
      );
      await repo.rebuildIndex();
      final jobs = await db.select(db.memoryJobs).get();
      expect(jobs, hasLength(2));
      expect(
        jobs.every((j) => j.state == 'pending' && j.attempts == 0),
        isTrue,
      );
      await db.intentionDao.eraseEverything();
      expect(await db.select(db.memories).get(), isEmpty);
      expect(await db.select(db.memoryRevisions).get(), isEmpty);
      expect(await db.select(db.memoryJobs).get(), isEmpty);
    },
  );

  test('blank capture is rejected without creating records', () async {
    await expectLater(repo.captureText(' \n ', at), throwsArgumentError);
    expect(await repo.watch().first, isEmpty);
  });

  test(
    'actual native memory DDL matches Drift columns and foreign keys',
    () async {
      final native = sqlite3.openInMemory();
      addTearDown(native.close);
      expect(nativeMemoryStatements(), hasLength(19));
      for (final sql in nativeMemoryStatements()) {
        expect(sql.toLowerCase(), isNot(contains('fts')));
        native.execute(sql);
      }
      await db.select(db.memories).get();
      for (final table in [
        'memories',
        'memory_revisions',
        'memory_events',
        'memory_jobs',
        'memory_vectors',
        'memory_links',
        'memory_attachments',
        'attachment_cleanup',
        'focus_sessions',
        'focus_events',
        'memory_collections',
        'collection_events',
        'memory_assignments',
        'routines',
        'routine_revisions',
        'routine_events',
        'routine_occurrences',
        'routine_occurrence_events',
        'local_reviews',
      ]) {
        final columns = await db
            .customSelect('PRAGMA table_info($table)')
            .get();
        expect(
          native
              .select('PRAGMA table_info($table)')
              .map((r) => r.values.toList())
              .toList(),
          columns.map((r) => r.data.values.toList()).toList(),
          reason: table,
        );
        final keys = await db
            .customSelect('PRAGMA foreign_key_list($table)')
            .get();
        expect(
          native
              .select('PRAGMA foreign_key_list($table)')
              .map((r) => r.values.toList())
              .toList(),
          keys.map((r) => r.data.values.toList()).toList(),
          reason: '$table foreign keys',
        );
      }
    },
  );

  test(
    'v2 migration preserves promises, reminders, events and preferences',
    () async {
      await db.close();
      final legacy = sqlite3.openInMemory();
      addTearDown(legacy.close);
      for (final sql in nativeV2CreateStatements) {
        legacy.execute(sql);
      }
      legacy.execute(
        "INSERT INTO intentions(id,source_app,source_package,raw_content,captured_at,reminder_at,updated_at) VALUES (42,'Shared','example.app','Original promise',100,200,100)",
      );
      legacy.execute(
        "INSERT INTO intention_events(intention_id,type,occurred_at,metadata) VALUES (42,'captured',100,'original')",
      );
      legacy.execute(
        "INSERT INTO preferences VALUES ('display_name','Sarwad')",
      );
      legacy.execute('PRAGMA user_version = 2');
      final before = legacy
          .select('SELECT * FROM intentions')
          .single
          .values
          .toList();
      db = CyaDatabase.forTesting(
        NativeDatabase.opened(legacy, closeUnderlyingOnClose: false),
      );
      repo = DriftMemoryRepository(db);
      await repo.captureText('A neutral thought', at);
      expect(
        legacy.select('SELECT * FROM intentions').single.values.toList(),
        before,
      );
      expect(
        legacy
            .select('SELECT metadata FROM intention_events')
            .single
            .values
            .single,
        'original',
      );
      expect(await db.preferenceDao.read('display_name'), 'Sarwad');
      expect(
        legacy.select('PRAGMA user_version').single.values.single,
        db.schemaVersion,
      );
      expect(legacy.select('PRAGMA foreign_key_check'), isEmpty);
    },
  );

  test(
    'failed migration rolls back new tables and retains the old version',
    () async {
      await db.close();
      final legacy = sqlite3.openInMemory();
      addTearDown(legacy.close);
      for (final sql in nativeV2CreateStatements) {
        legacy.execute(sql);
      }
      // Deliberately obstruct the third new table after the first two were created.
      legacy.execute('CREATE TABLE memory_events (broken TEXT)');
      legacy.execute('PRAGMA user_version = 2');
      db = CyaDatabase.forTesting(
        NativeDatabase.opened(legacy, closeUnderlyingOnClose: false),
      );
      await expectLater(db.select(db.memories).get(), throwsA(anything));
      expect(
        legacy.select("SELECT name FROM sqlite_master WHERE name = 'memories'"),
        isEmpty,
      );
      expect(legacy.select('PRAGMA user_version').single.values.single, 2);
    },
  );

  test(
    'future schema is refused without silently downgrading its version',
    () async {
      final future = sqlite3.openInMemory()
        ..execute('PRAGMA user_version = 999');
      addTearDown(future.close);
      await db.close();
      db = CyaDatabase.forTesting(
        NativeDatabase.opened(future, closeUnderlyingOnClose: false),
      );
      await expectLater(db.select(db.memories).get(), throwsA(anything));
      expect(future.select('PRAGMA user_version').single.values.single, 999);
    },
  );

  for (final nativeFirst in [false, true]) {
    test(
      'v3→v4 preserves memory originals/jobs (${nativeFirst ? 'native' : 'Dart'} first)',
      () async {
        await db.close();
        final legacy = sqlite3.openInMemory();
        addTearDown(legacy.close);
        for (final sql in nativeV2CreateStatements) {
          legacy.execute(sql);
        }
        for (final sql in nativeMemoryStatements().take(4)) {
          final original = sql
              .split('\n')
              .where(
                (line) => !RegExp(
                  r'^\s*(next_segment|model_version|metadata)\s',
                ).hasMatch(line),
              )
              .join('\n')
              .replaceAll(RegExp(r',\s*\)'), ')');
          legacy.execute(original);
        }
        legacy.execute(
          "INSERT INTO memories(id,captured_at,updated_at) VALUES ('source',100,100)",
        );
        legacy.execute(
          "INSERT INTO memory_revisions VALUES ('original','source',1,'Original retained',100)",
        );
        legacy.execute(
          "INSERT INTO memory_events(memory_id,type,occurred_at,revision_id) VALUES ('source','captured',100,'original')",
        );
        legacy.execute(
          "INSERT INTO memory_jobs(revision_id) VALUES ('original')",
        );
        legacy.execute('PRAGMA user_version=3');
        if (nativeFirst) {
          final kotlin = File(
            'android/app/src/main/kotlin/dev/cya/app/capture/CyaDatabaseContract.kt',
          ).readAsStringSync();
          legacy.execute('BEGIN IMMEDIATE');
          for (final match in RegExp(
            '"(ALTER TABLE memory_[^"]+)"',
          ).allMatches(kotlin)) {
            legacy.execute(match.group(1)!);
          }
          for (final sql in nativeMemoryStatements().skip(4)) {
            legacy.execute(sql);
          }
          legacy.execute('PRAGMA user_version=8');
          legacy.execute('COMMIT');
        }
        db = CyaDatabase.forTesting(
          NativeDatabase.opened(legacy, closeUnderlyingOnClose: false),
        );
        repo = DriftMemoryRepository(db);
        expect((await repo.watch().first).single.text, 'Original retained');
        final job = (await db.select(db.memoryJobs).get()).single;
        expect(job.nextSegment, 0);
        expect(job.modelVersion, isNull);
        expect(
          (await db.select(db.memoryEvents).get()).single.metadata,
          isNull,
        );
        expect(await db.select(db.memoryLinks).get(), isEmpty);
        expect(
          legacy.select('PRAGMA user_version').single.values.single,
          db.schemaVersion,
        );
        expect(legacy.select('PRAGMA foreign_key_check'), isEmpty);
      },
    );
  }
}
