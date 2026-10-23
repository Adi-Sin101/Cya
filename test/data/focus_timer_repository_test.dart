import 'dart:convert';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/focus_repository.dart';
import 'package:cya/data/repositories/focus_timer_repository.dart';
import 'package:cya/data/services/backup_import.dart';
import 'package:cya/domain/services/data_export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CyaDatabase db;
  final at = DateTime(2026, 10, 16, 12);
  setUp(() => db = CyaDatabase.memory());
  tearDown(() => db.close());
  test(
    'chosen clock survives repository recreation and background time without completing work',
    () async {
      final repo = FocusTimerRepository(db);
      await repo.start('Read one page', 25, at);
      final restored = (await FocusTimerRepository(db).load())!;
      expect(restored.remainingAt(at.add(const Duration(minutes: 4))), 1260);
      expect(restored.remainingAt(at.add(const Duration(hours: 1))), 0);
      expect(restored.remainingAt(at.subtract(const Duration(hours: 1))), 1500);
      expect(await db.select(db.routineOccurrences).get(), isEmpty);
      expect(await db.select(db.intentions).get(), isEmpty);
      expect((await db.select(db.focusSessions).get()).single.endedAt, isNull);
    },
  );
  test(
    'pause holds remaining time, resume establishes a new deadline, stop ends existing session',
    () async {
      final repo = FocusTimerRepository(db),
          timer = await repo.start('Practice', 15, at);
      final paused = await repo.toggle(
        timer.sessionId,
        at.add(const Duration(minutes: 3)),
      );
      expect(paused.running, isFalse);
      expect(paused.remainingAt(at.add(const Duration(hours: 2))), 720);
      final resumed = await repo.toggle(
        timer.sessionId,
        at.add(const Duration(minutes: 20)),
      );
      expect(resumed.remainingAt(at.add(const Duration(minutes: 21))), 660);
      await repo.stop(timer.sessionId, at.add(const Duration(minutes: 22)));
      expect(await repo.load(), isNull);
      expect(await db.preferenceDao.read(focusPriorityKey), '');
      expect((await db.select(db.focusEvents).get()).map((e) => e.type), [
        'started',
        'timer_started',
        'timer_paused',
        'timer_resumed',
        'timer_stopped',
        'ended',
      ]);
    },
  );
  test('stale room cannot pause or end a newly chosen priority', () async {
    final repo = FocusTimerRepository(db),
        old = await repo.start('Earlier priority', 25, at);
    await FocusRepository(
      db,
    ).select('New choice', at.add(const Duration(minutes: 1)));
    await expectLater(repo.toggle(old.sessionId, at), throwsStateError);
    await expectLater(repo.stop(old.sessionId, at), throwsStateError);
    expect(await db.preferenceDao.read(focusPriorityKey), 'New choice');
  });
  test('event failure rolls back priority, session and clock together', () async {
    await db.customStatement(
      "CREATE TRIGGER fail_clock BEFORE INSERT ON focus_events WHEN NEW.type='timer_started' BEGIN SELECT RAISE(ABORT,'fixture'); END",
    );
    await expectLater(
      FocusTimerRepository(db).start('Keep this atomic', 25, at),
      throwsA(anything),
    );
    expect(await db.select(db.focusSessions).get(), isEmpty);
    expect(await db.select(db.focusEvents).get(), isEmpty);
    expect(await db.preferenceDao.read(focusPriorityKey), isNull);
    expect(await db.preferenceDao.read(focusTimerKey), isNull);
  });
  test(
    'new clock closes earlier clock, invalid durations and corrupt projection are safe',
    () async {
      final repo = FocusTimerRepository(db),
          old = await repo.start('Same priority', 15, at);
      final next = await repo.start(
        'Same priority',
        25,
        at.add(const Duration(minutes: 2)),
      );
      expect(next.sessionId, isNot(old.sessionId));
      expect(
        (await db.select(db.focusSessions).get()).where(
          (s) => s.endedAt == null,
        ),
        hasLength(1),
      );
      await expectLater(repo.start('Bad duration', 0, at), throwsArgumentError);
      await db.preferenceDao.write(focusTimerKey, 'not json');
      expect(await repo.load(), isNull);
      expect(await db.preferenceDao.read(focusPriorityKey), 'Same priority');
    },
  );
  test(
    'portable history accepts clock events but never exports a device-running clock',
    () async {
      final repo = FocusTimerRepository(db),
          timer = await repo.start('Local focus', 25, at);
      await repo.toggle(timer.sessionId, at.add(const Duration(minutes: 1)));
      final document = DataExport.build(
        exportedAt: at,
        intentions: [],
        events: [],
        preferences: await db.preferenceDao.all(),
        focusSessions: [
          for (final r in await db.select(db.focusSessions).get()) r.toJson(),
        ],
        focusEvents: [
          for (final r in await db.select(db.focusEvents).get()) r.toJson(),
        ],
      );
      expect(
        (document['preferences'] as Map).containsKey(focusTimerKey),
        isFalse,
      );
      expect(
        BackupImport.parse(jsonEncode(document)).focusEvents,
        hasLength(3),
      );
    },
  );
}
