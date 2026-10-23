import 'dart:convert';
import 'dart:io';

import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/routine_repository.dart';
import 'package:cya/data/services/backup_import.dart';
import 'package:cya/data/services/local_audio_files.dart';
import 'package:cya/domain/entities/routine.dart';
import 'package:cya/domain/services/data_export.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'native_contract_test.dart'
    show nativeMemoryStatements, nativeV2CreateStatements;

void main() {
  late CyaDatabase db;
  late RoutineRepository repo;
  final at = DateTime(2026, 10, 16, 12);
  setUp(() {
    db = CyaDatabase.memory();
    repo = RoutineRepository(db);
  });
  tearDown(() => db.close());
  Future<String> create([String title = 'My routine']) => repo.save(
    expectedRevision: 0,
    title: title,
    steps: ['Read', 'Reflect'],
    weekdays: 16,
    start: 540,
    end: 600,
    fallback: 'Read one paragraph',
    at: at,
  );
  test(
    'weekday suggestions never create occurrences; selection is explicit and idempotent',
    () async {
      final id = await create();
      final routine = (await repo.watch().first).single;
      expect(routine.eligible(at), isTrue);
      expect(routine.eligible(DateTime(2026, 10, 17)), isFalse);
      expect(await db.select(db.routineOccurrences).get(), isEmpty);
      final occurrence = await repo.select(id, at, at);
      expect(await repo.select(id, at, at), occurrence);
      expect(await db.select(db.routineOccurrences).get(), hasLength(1));
      expect(await db.select(db.routineOccurrenceEvents).get(), hasLength(1));
      expect(await db.select(db.intentions).get(), isEmpty);
      // An intentional unusual-day selection is allowed, never inferred.
      await repo.select(id, DateTime(2026, 10, 17), at);
      expect(await db.select(db.routineOccurrences).get(), hasLength(2));
    },
  );
  test(
    'editing a routine keeps occurrence version and source steps immutable',
    () async {
      final id = await create();
      await repo.select(id, at, at);
      final original = (await repo.occurrences(at).first).single;
      await repo.save(
        id: id,
        expectedRevision: 1,
        title: 'Changed routine',
        steps: ['Different step'],
        at: at,
      );
      final old = (await repo.occurrences(at).first).single;
      expect(old.revisionId, original.revisionId);
      expect(old.title, 'My routine');
      expect(old.steps, ['Read', 'Reflect']);
      expect((await repo.watch().first).single.title, 'Changed routine');
      expect(await db.select(db.routineRevisions).get(), hasLength(2));
      await expectLater(
        repo.save(
          id: id,
          expectedRevision: 1,
          title: 'Stale',
          steps: [],
          at: at,
        ),
        throwsStateError,
      );
    },
  );
  test(
    'shorten, defer, pause and resume retain snapshots and reject stale changes',
    () async {
      final id = await create();
      await repo.select(id, at, at);
      var occurrence = (await repo.occurrences(at).first).single;
      await repo.change(
        occurrence.id,
        at,
        expectedVersion: 1,
        steps: ['Read one paragraph'],
      );
      await expectLater(
        repo.change(occurrence.id, at, expectedVersion: 1, state: 'completed'),
        throwsStateError,
      );
      occurrence = (await repo.occurrences(at).first).single;
      final tomorrow = DateTime(2026, 10, 17);
      await repo.pauseAfterDisruption(
        occurrence.id,
        tomorrow,
        at,
        expectedVersion: occurrence.version,
      );
      expect((await repo.watch().first).single.paused, isTrue);
      expect(await repo.occurrences(at).first, isEmpty);
      final deferred = (await repo.occurrences(tomorrow).first).single;
      expect(deferred.state, 'deferred');
      expect(deferred.selectedDay, '2026-10-16');
      expect(deferred.steps, ['Read one paragraph']);
      expect(
        (await db.select(db.routineRevisions).get()).single.steps,
        jsonEncode(['Read', 'Reflect']),
      );
      await repo.pause(id, false, at);
      expect(await repo.select(id, tomorrow, at), deferred.id);
      await repo.change(
        deferred.id,
        at,
        expectedVersion: deferred.version,
        state: 'completed',
      );
      expect(
        (await repo.occurrences(tomorrow).first).single.state,
        'completed',
      );
      expect(await db.select(db.routineOccurrenceEvents).get(), hasLength(4));
    },
  );
  test(
    'failed occurrence event rolls back both defer and routine pause',
    () async {
      final id = await create();
      final selected = await repo.select(id, at, at);
      await db.customStatement(
        "CREATE TRIGGER reject_occurrence BEFORE INSERT ON routine_occurrence_events BEGIN SELECT RAISE(ABORT,'fixture'); END",
      );
      await expectLater(
        repo.pauseAfterDisruption(
          selected,
          DateTime(2026, 10, 17),
          at,
          expectedVersion: 1,
        ),
        throwsA(anything),
      );
      expect((await repo.occurrences(at).first).single.state, 'planned');
      expect((await repo.watch().first).single.paused, isFalse);
      expect(await db.select(db.routineOccurrenceEvents).get(), hasLength(1));
    },
  );
  test('failed routine event rolls back definition edit and version', () async {
    final id = await create();
    await db.customStatement(
      "CREATE TRIGGER reject_routine BEFORE INSERT ON routine_events BEGIN SELECT RAISE(ABORT,'fixture'); END",
    );
    await expectLater(
      repo.save(
        id: id,
        expectedRevision: 1,
        title: 'Changed',
        steps: [],
        at: at,
      ),
      throwsA(anything),
    );
    expect((await repo.watch().first).single.title, 'My routine');
    expect(await db.select(db.routineRevisions).get(), hasLength(1));
  });
  test(
    'routine and day reordering swap neighbors; removal preserves past outcomes',
    () async {
      final a = await create('First'), b = await create('Second');
      await repo.reorder([b, a], at);
      expect((await repo.watch().first).map((r) => r.id), [b, a]);
      final first = await repo.select(a, at, at);
      await repo.select(b, at, at);
      await repo.moveOccurrence(first, 1, at, expectedVersion: 1);
      expect((await repo.occurrences(at).first).map((o) => o.routineId), [
        b,
        a,
      ]);
      await repo.remove(a, at);
      expect((await repo.watch().first).map((r) => r.id), [b]);
      expect((await repo.occurrences(at).first).map((o) => o.routineId), [
        b,
        a,
      ]);
      expect(await db.select(db.routineRevisions).get(), hasLength(2));
      await repo.remove(a, at, restore: true);
      expect(
        (await repo.watch().first).firstWhere((r) => r.id == a).paused,
        isTrue,
      );
    },
  );
  test(
    'day rollover retains open plans and recurrence uses calendar weekdays',
    () async {
      final id = await create();
      await repo.select(id, at, at);
      final tomorrow = DateTime(2026, 10, 17);
      expect(await repo.occurrences(tomorrow).first, isEmpty);
      expect(
        (await repo.occurrences(tomorrow, earlierOpen: true).first)
            .single
            .state,
        'planned',
      );
      expect((await repo.watch().first).single.eligible(tomorrow), isFalse);
      expect(localDayKey(parseLocalDay('2028-02-29')), '2028-02-29');
      expect(() => parseLocalDay('2026-02-30'), throwsFormatException);
    },
  );
  test(
    'review is read-only, period bounded, explicit outcomes; notes reuse memory history/jobs',
    () async {
      final id = await create();
      final selected = await repo.select(id, at, at);
      await repo.change(selected, at, expectedVersion: 1, state: 'skipped');
      final before = (await db.select(db.routineEvents).get()).length;
      final facts = await repo.facts(at, 'daily');
      expect(facts.routinesSelected, 1);
      expect(facts.routineStates['skipped'], 1);
      expect(facts.routineStates['completed'], 0);
      expect(await db.select(db.routineEvents).get(), hasLength(before));
      expect(
        (await repo.facts(
          DateTime(2026, 10, 17),
          'daily',
        )).routineStates.values.every((n) => n == 0),
        isTrue,
      );
      final memory = await repo.saveReview(
        at,
        'weekly',
        'What helped me today',
        at,
        expectedRevision: 0,
      );
      await repo.saveReview(
        at,
        'weekly',
        'What I changed my mind about',
        at,
        expectedRevision: 1,
      );
      expect((await repo.reviewNote(at, 'weekly'))!.revision, 2);
      expect(
        (await db.select(db.localReviews).get()).single.dayKey,
        '2026-10-12',
      );
      expect((await db.select(db.localReviews).get()).single.memoryId, memory);
      expect(await db.select(db.memoryRevisions).get(), hasLength(2));
      expect(await db.select(db.memoryJobs).get(), hasLength(2));
    },
  );
  test(
    'three explicit deferrals explain a suggestion but never change routine settings',
    () async {
      final id = await create(), selected = await repo.select(id, at, at);
      for (var i = 1; i <= 3; i++) {
        await repo.change(
          selected,
          at.add(Duration(minutes: i)),
          expectedVersion: i,
          state: 'deferred',
          day: DateTime(2026, 10, 16 + i),
        );
      }
      final facts = await repo.facts(at, 'weekly');
      expect(facts.adjustmentEvidence.single, contains('3 explicit deferrals'));
      expect((await repo.watch().first).single.start, 540);
      expect((await repo.watch().first).single.paused, isFalse);
    },
  );

  Future<Map<String, Object?>> snapshot() async => DataExport.build(
    exportedAt: at,
    intentions: [],
    events: [],
    preferences: {},
    memories: [for (final r in await db.select(db.memories).get()) r.toJson()],
    memoryRevisions: [
      for (final r in await db.select(db.memoryRevisions).get()) r.toJson(),
    ],
    memoryEvents: [
      for (final r in await db.select(db.memoryEvents).get()) r.toJson(),
    ],
    routines: [for (final r in await db.select(db.routines).get()) r.toJson()],
    routineRevisions: [
      for (final r in await db.select(db.routineRevisions).get()) r.toJson(),
    ],
    routineEvents: [
      for (final r in await db.select(db.routineEvents).get()) r.toJson(),
    ],
    routineOccurrences: [
      for (final r in await db.select(db.routineOccurrences).get()) r.toJson(),
    ],
    routineOccurrenceEvents: [
      for (final r in await db.select(db.routineOccurrenceEvents).get())
        r.toJson(),
    ],
    localReviews: [
      for (final r in await db.select(db.localReviews).get()) r.toJson(),
    ],
  );
  test(
    'routine/review backup remaps snapshot histories and rejects tampering',
    () async {
      final id = await create(), selected = await repo.select(id, at, at);
      await repo.change(selected, at, expectedVersion: 1, state: 'completed');
      await repo.saveReview(
        at,
        'daily',
        'My own note',
        at,
        expectedRevision: 0,
      );
      final document = await snapshot();
      final corrupt = jsonDecode(jsonEncode(document)) as Map<String, dynamic>;
      corrupt['routineOccurrences'][0]['state'] = 'skipped';
      expect(
        () => BackupImport.parse(jsonEncode(corrupt)),
        throwsFormatException,
      );
      // Event arrays may be shuffled in a portable file; original ids preserve order.
      document['routineOccurrenceEvents'] =
          (document['routineOccurrenceEvents'] as List).reversed.toList();
      final backup = BackupImport.parse(jsonEncode(document)),
          target = CyaDatabase.memory(),
          root = await Directory.systemTemp.createTemp('cya-routine-import-');
      try {
        await RoutineRepository(target).saveReview(
          at,
          'daily',
          'Keep the current local review',
          at,
          expectedRevision: 0,
        );
        await backup.append(
          target,
          files: LocalAudioFiles(directory: () async => root),
          copyAttachments: (_) async {},
        );
        final imported = RoutineRepository(target),
            occurrence = (await imported.occurrences(at).first).single;
        expect(occurrence.id, isNot(selected));
        expect(occurrence.routineId, isNot(id));
        expect(occurrence.state, 'completed');
        expect(
          (await imported.facts(at, 'daily')).routineStates['completed'],
          1,
        );
        expect(
          (await imported.reviewNote(at, 'daily'))!.text,
          'Keep the current local review',
        );
        final reviewCopies = await target.select(target.localReviews).get();
        expect(reviewCopies, hasLength(2));
        expect(
          reviewCopies.where((r) => r.origin.startsWith('import:')),
          hasLength(1),
        );
        expect(
          (await target.select(target.memoryRevisions).get()).map(
            (r) => r.body,
          ),
          contains('My own note'),
        );
        expect(
          await target.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
        // A second export/import validation must accept remapped metadata history.
        final copied = DataExport.build(
          exportedAt: at,
          intentions: [],
          events: [],
          preferences: {},
          memories: [
            for (final r in await target.select(target.memories).get())
              r.toJson(),
          ],
          memoryRevisions: [
            for (final r in await target.select(target.memoryRevisions).get())
              r.toJson(),
          ],
          memoryEvents: [
            for (final r in await target.select(target.memoryEvents).get())
              r.toJson(),
          ],
          routines: [
            for (final r in await target.select(target.routines).get())
              r.toJson(),
          ],
          routineRevisions: [
            for (final r in await target.select(target.routineRevisions).get())
              r.toJson(),
          ],
          routineEvents: [
            for (final r in await target.select(target.routineEvents).get())
              r.toJson(),
          ],
          routineOccurrences: [
            for (final r
                in await target.select(target.routineOccurrences).get())
              r.toJson(),
          ],
          routineOccurrenceEvents: [
            for (final r
                in await target.select(target.routineOccurrenceEvents).get())
              r.toJson(),
          ],
          localReviews: [
            for (final r in await target.select(target.localReviews).get())
              r.toJson(),
          ],
        );
        expect(
          BackupImport.parse(jsonEncode(copied)).routineData.routines,
          hasLength(1),
        );
      } finally {
        await target.close();
        await root.delete(recursive: true);
      }
    },
  );
  for (final nativeFirst in [false, true]) {
    test(
      'schema7 to8 retains memory/history (${nativeFirst ? 'native' : 'Dart'} first)',
      () async {
        await db.close();
        final legacy = sqlite3.openInMemory();
        addTearDown(legacy.close);
        for (final sql in nativeV2CreateStatements) {
          legacy.execute(sql);
        }
        for (final sql in nativeMemoryStatements().take(13)) {
          legacy.execute(sql);
        }
        legacy.execute(
          "INSERT INTO memories(id,captured_at,updated_at) VALUES ('old',100,100)",
        );
        legacy.execute(
          "INSERT INTO memory_revisions VALUES ('original','old',1,'Preserved',100)",
        );
        legacy.execute('PRAGMA user_version=7');
        if (nativeFirst) {
          legacy.execute('BEGIN IMMEDIATE');
          for (final sql in nativeMemoryStatements().skip(13)) {
            legacy.execute(sql);
          }
          legacy.execute('PRAGMA user_version=8');
          legacy.execute('COMMIT');
        }
        db = CyaDatabase.forTesting(
          NativeDatabase.opened(legacy, closeUnderlyingOnClose: false),
        );
        repo = RoutineRepository(db);
        await create();
        expect(
          (await db.select(db.memoryRevisions).get()).single.body,
          'Preserved',
        );
        expect(legacy.select('PRAGMA foreign_key_check'), isEmpty);
        expect(legacy.select('PRAGMA user_version').single.values.single, 8);
      },
    );
  }
}
