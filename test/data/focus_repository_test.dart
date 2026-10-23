import 'dart:io';

import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/focus_repository.dart';
import 'package:cya/data/services/backup_import.dart';
import 'package:cya/data/services/local_audio_files.dart';
import 'package:cya/domain/services/data_export.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'native_contract_test.dart'
    show nativeMemoryStatements, nativeV2CreateStatements;

void main() {
  late CyaDatabase db;
  late FocusRepository repo;
  final at = DateTime(2026, 10, 16);
  setUp(() {
    db = CyaDatabase.memory();
    repo = FocusRepository(db);
  });
  tearDown(() => db.close());

  test(
    'switch and end preserve priorities and transactional focus events',
    () async {
      await repo.select('Read the chapter', at);
      await repo.select('Read the chapter', at);
      await repo.select('Write the draft', at.add(const Duration(minutes: 30)));
      var sessions = await repo.history().first;
      expect(sessions, hasLength(2));
      expect(sessions.first.priority, 'Write the draft');
      expect(sessions.first.endedAt, isNull);
      expect(sessions.last.endedAt, at.add(const Duration(minutes: 30)));
      expect(await db.select(db.focusEvents).get(), hasLength(3));
      await repo.select('', at.add(const Duration(hours: 1)));
      sessions = await repo.history().first;
      expect(sessions.every((s) => s.endedAt != null), isTrue);
      expect(await db.preferenceDao.read(focusPriorityKey), '');
      expect(await db.select(db.focusEvents).get(), hasLength(4));
    },
  );
  test(
    'failed event rolls back session end, new priority and preference',
    () async {
      await repo.select('Original chosen priority', at);
      await db.customStatement(
        "CREATE TRIGGER fail_focus BEFORE INSERT ON focus_events BEGIN SELECT RAISE(ABORT,'fixture'); END",
      );
      await expectLater(
        repo.select('New priority', at.add(const Duration(minutes: 10))),
        throwsA(anything),
      );
      expect(
        (await repo.history().first).single.priority,
        'Original chosen priority',
      );
      expect((await repo.history().first).single.endedAt, isNull);
      expect(
        await db.preferenceDao.read(focusPriorityKey),
        'Original chosen priority',
      );
      expect(await db.select(db.focusEvents).get(), hasLength(1));
    },
  );
  test(
    'focus import preserves history and explicitly ends copies without changing local focus',
    () async {
      await repo.select('Exported priority', at);
      final manifest = DataExport.encode(
        DataExport.build(
          exportedAt: at,
          intentions: [],
          events: [],
          preferences: {},
          focusSessions: [
            for (final s in await db.select(db.focusSessions).get()) s.toJson(),
          ],
          focusEvents: [
            for (final e in await db.select(db.focusEvents).get()) e.toJson(),
          ],
        ),
      );
      final backup = BackupImport.parse(manifest);
      final target = CyaDatabase.memory();
      final root = await Directory.systemTemp.createTemp('cya-focus-test-');
      try {
        await FocusRepository(target).select('Keep my current session', at);
        await backup.append(
          target,
          files: LocalAudioFiles(directory: () async => root),
          copyAttachments: (_) async {},
        );
        final sessions = await target.select(target.focusSessions).get();
        expect(
          sessions.where((s) => s.endedAt == null).single.priority,
          'Keep my current session',
        );
        expect(
          sessions
              .singleWhere((s) => s.priority == 'Exported priority')
              .endedAt,
          isNotNull,
        );
        expect(
          (await target.select(target.focusEvents).get()).map((e) => e.type),
          contains('import_ended'),
        );
        expect(
          await target.preferenceDao.read(focusPriorityKey),
          'Keep my current session',
        );
      } finally {
        await target.close();
        await root.delete(recursive: true);
      }
    },
  );
  for (final version in [4, 5]) {
    for (final nativeFirst in [false, true]) {
      test(
        'v$version to current preserves memory and model metadata (${nativeFirst ? 'native' : 'Dart'} first)',
        () async {
          await db.close();
          final legacy = sqlite3.openInMemory();
          addTearDown(legacy.close);
          for (final sql in nativeV2CreateStatements) {
            legacy.execute(sql);
          }
          for (final sql in nativeMemoryStatements().take(
            version == 4 ? 6 : 8,
          )) {
            legacy.execute(sql);
          }
          legacy.execute(
            "INSERT INTO memories(id,captured_at,updated_at) VALUES ('old',100,100)",
          );
          legacy.execute(
            "INSERT INTO memory_revisions VALUES ('r','old',1,'Keep original',100)",
          );
          legacy.execute(
            "INSERT INTO memory_jobs(revision_id,model_version,next_segment) VALUES ('r','old-model',2)",
          );
          legacy.execute('PRAGMA user_version=$version');
          legacy.execute(
            "INSERT INTO preferences VALUES ('focus_priority','Legacy chosen priority')",
          );
          if (nativeFirst) {
            legacy.execute('BEGIN IMMEDIATE');
            for (final sql in nativeMemoryStatements().skip(
              version == 4 ? 6 : 8,
            )) {
              legacy.execute(sql);
            }
            final kotlin = File(
              'android/app/src/main/kotlin/dev/cya/app/capture/CyaDatabaseContract.kt',
            ).readAsStringSync();
            for (final match in RegExp(
              '"(INSERT INTO focus_[^"]+)"',
            ).allMatches(kotlin)) {
              legacy.execute(match.group(1)!);
            }
            legacy.execute('PRAGMA user_version=8');
            legacy.execute('COMMIT');
          }
          db = CyaDatabase.forTesting(
            NativeDatabase.opened(legacy, closeUnderlyingOnClose: false),
          );
          repo = FocusRepository(db);
          await repo.select('New priority', at);
          expect(
            (await repo.history().first).map((s) => s.priority),
            contains('Legacy chosen priority'),
          );
          expect(
            (await db.select(db.focusEvents).get()).map((e) => e.type),
            contains('legacy_observed'),
          );
          expect(
            (await db.select(db.memoryRevisions).get()).single.body,
            'Keep original',
          );
          expect(
            (await db.select(db.memoryJobs).get()).single.modelVersion,
            'old-model',
          );
          expect((await db.select(db.memoryJobs).get()).single.nextSegment, 2);
          expect(legacy.select('PRAGMA foreign_key_check'), isEmpty);
          expect(legacy.select('PRAGMA user_version').single.values.single, db.schemaVersion);
        },
      );
    }
  }
}
