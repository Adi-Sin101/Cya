import 'package:cya/data/db/cya_database.dart';
import 'package:cya/domain/entities/intention.dart';
import 'package:flutter_test/flutter_test.dart';

/// A forgotten reminder is fatal for a memory product (PRD §12), so the app
/// detects dropped alarms instead of trusting the OS. Every fired reminder
/// writes a `resurfaced` event — these tests pin that their *absence* is what
/// counts as evidence.
void main() {
  late CyaDatabase db;
  final now = DateTime(2026, 3, 4, 18, 30);

  setUp(() => db = CyaDatabase.memory());
  tearDown(() => db.close());

  Future<int> capture({required DateTime reminderAt}) =>
      db.intentionDao.capture(
        NewIntention(
          sourceApp: 'Messenger',
          rawContent: 'Reply to Sarah',
          capturedAt: now.subtract(const Duration(days: 1)),
          reminderAt: reminderAt,
        ),
      );

  test('a due promise that never resurfaced is reported as missed', () async {
    await capture(reminderAt: now.subtract(const Duration(hours: 2)));
    expect(await db.intentionDao.missedReminders(now), hasLength(1));
  });

  test('a promise that did resurface is not missed', () async {
    final id = await capture(
      reminderAt: now.subtract(const Duration(hours: 2)),
    );
    await db.intentionDao.markResurfaced(
      id,
      at: now.subtract(const Duration(hours: 2)),
      tier: 'quiet',
    );
    expect(await db.intentionDao.missedReminders(now), isEmpty);
  });

  test('a reminder still inside the grace window is not yet missed', () async {
    await capture(reminderAt: now.subtract(const Duration(minutes: 2)));
    expect(await db.intentionDao.missedReminders(now), isEmpty);
  });

  test('a future reminder is not missed', () async {
    await capture(reminderAt: now.add(const Duration(hours: 3)));
    expect(await db.intentionDao.missedReminders(now), isEmpty);
  });

  test('a resolved promise is never missed, even if it never fired', () async {
    final id = await capture(
      reminderAt: now.subtract(const Duration(hours: 5)),
    );
    await db.intentionDao.resolve(id, at: now);
    expect(await db.intentionDao.missedReminders(now), isEmpty);
  });

  test('an old resurface does not excuse a newly snoozed reminder', () async {
    final id = await capture(
      reminderAt: now.subtract(const Duration(hours: 6)),
    );
    await db.intentionDao.markResurfaced(
      id,
      at: now.subtract(const Duration(hours: 6)),
      tier: 'quiet',
    );
    // The user snoozed it to an hour ago; that reminder never arrived.
    await db.intentionDao.snooze(
      id,
      until: now.subtract(const Duration(hours: 1)),
      at: now.subtract(const Duration(hours: 6)),
    );

    expect(await db.intentionDao.missedReminders(now), hasLength(1));
  });

  test('resurfacing is recorded with its escalation tier', () async {
    final id = await capture(
      reminderAt: now.subtract(const Duration(hours: 1)),
    );
    await db.intentionDao.markResurfaced(id, at: now, tier: 'banner');

    final events = await db.intentionDao.watchEventsFor(id).first;
    expect(events.last.metadata, contains('"tier":"banner"'));
  });
}
