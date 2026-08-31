import 'package:cya/data/db/cya_database.dart';
import 'package:cya/domain/entities/intention.dart';
import 'package:cya/domain/enums/intention_event_type.dart';
import 'package:cya/domain/enums/intention_status.dart';
import 'package:cya/domain/projections/week_projection.dart';
import 'package:flutter_test/flutter_test.dart';

/// The store is the single source of truth (PRD §3.3) and every state change
/// must land in the append-only log (§7.1). These run against a real SQLite
/// database, so they also pin the FTS index and the trigger wiring the native
/// capture path depends on.
void main() {
  late CyaDatabase db;
  final now = DateTime(2026, 3, 4, 18, 30);

  setUp(() => db = CyaDatabase.memory());
  tearDown(() => db.close());

  NewIntention sample({
    String content = 'Reply to Sarah about the trip',
    String app = 'Messenger',
    DateTime? reminderAt,
  }) => NewIntention(
    sourceApp: app,
    rawContent: content,
    snippet: 'are we still on for saturday?',
    capturedAt: now,
    reminderAt: reminderAt ?? DateTime(2026, 3, 4, 20),
  );

  group('capture', () {
    test('writes the row and a captured event together', () async {
      final id = await db.intentionDao.capture(sample());

      final stored = await db.intentionDao.findById(id);
      expect(stored, isNotNull);
      expect(stored!.status, IntentionStatus.open);
      expect(stored.snoozeCount, 0);
      expect(stored.sourceApp, 'Messenger');

      final events = await db.intentionDao.watchEventsFor(id).first;
      expect(events, hasLength(1));
      expect(events.single.type, IntentionEventType.captured);
    });

    test('is searchable immediately through the FTS index', () async {
      await db.intentionDao.capture(sample());
      expect(await db.intentionDao.search('sarah'), hasLength(1));
      expect(await db.intentionDao.search('SAR'), hasLength(1)); // prefix
      expect(await db.intentionDao.search('groceries'), isEmpty);
    });

    test('search survives punctuation and FTS metacharacters', () async {
      await db.intentionDao.capture(sample());
      expect(await db.intentionDao.search('   '), isEmpty);
      // Quotes and operators are escaped into plain terms, not syntax.
      expect(await db.intentionDao.search('"; drop table'), isEmpty);
      expect(await db.intentionDao.search('sarah"'), hasLength(1));
    });
  });

  group('resolve / reopen', () {
    test('resolving logs a resolved event and flips the status', () async {
      final id = await db.intentionDao.capture(sample());
      await db.intentionDao.resolve(id, at: now);

      expect(
        (await db.intentionDao.findById(id))!.status,
        IntentionStatus.resolved,
      );
      final events = await db.intentionDao.watchEventsFor(id).first;
      expect(events.map((e) => e.type), <IntentionEventType>[
        IntentionEventType.captured,
        IntentionEventType.resolved,
      ]);
    });

    test('reopening is recorded rather than erasing the resolution', () async {
      final id = await db.intentionDao.capture(sample());
      await db.intentionDao.resolve(id, at: now);
      await db.intentionDao.reopen(id, at: now.add(const Duration(minutes: 1)));

      expect(
        (await db.intentionDao.findById(id))!.status,
        IntentionStatus.open,
      );
      final events = await db.intentionDao.watchEventsFor(id).first;
      expect(events, hasLength(3));
      expect(events.last.type, IntentionEventType.edited);
    });
  });

  group('snooze', () {
    test('pushes the reminder out and counts the snooze', () async {
      final id = await db.intentionDao.capture(sample());
      final until = now.add(const Duration(hours: 3));
      await db.intentionDao.snooze(id, until: until, at: now);

      final stored = (await db.intentionDao.findById(id))!;
      expect(stored.status, IntentionStatus.snoozed);
      expect(stored.snoozeCount, 1);
      expect(stored.reminderAt, until);

      final events = await db.intentionDao.watchEventsFor(id).first;
      expect(events.last.type, IntentionEventType.snoozed);
      expect(events.last.metadata, contains('"count":1'));
    });

    test('accumulates across repeated snoozes', () async {
      final id = await db.intentionDao.capture(sample());
      for (var i = 1; i <= 3; i++) {
        await db.intentionDao.snooze(
          id,
          until: now.add(Duration(hours: i)),
          at: now,
        );
      }
      expect((await db.intentionDao.findById(id))!.snoozeCount, 3);
    });
  });

  group('today', () {
    test('includes overdue and today, excludes later and archived', () async {
      final dayStart = WeekProjection.startOfDay(now);
      final dayEnd = WeekProjection.endOfDay(now);

      await db.intentionDao.capture(
        sample(
          content: 'overdue',
          reminderAt: now.subtract(const Duration(days: 2)),
        ),
      );
      await db.intentionDao.capture(
        sample(content: 'tonight', reminderAt: DateTime(2026, 3, 4, 20)),
      );
      await db.intentionDao.capture(
        sample(content: 'next week', reminderAt: DateTime(2026, 3, 12, 9)),
      );
      final archivedId = await db.intentionDao.capture(
        sample(content: 'archived', reminderAt: DateTime(2026, 3, 4, 21)),
      );
      await db.intentionDao.archive(archivedId, at: now);

      final today = await db.intentionDao.watchToday(dayStart, dayEnd).first;
      expect(today.map((i) => i.title), <String>['overdue', 'tonight']);
    });

    test('keeps promises resolved today so the ring shows the work', () async {
      final dayStart = WeekProjection.startOfDay(now);
      final dayEnd = WeekProjection.endOfDay(now);
      final id = await db.intentionDao.capture(
        sample(content: 'done today', reminderAt: DateTime(2026, 3, 4, 9)),
      );
      await db.intentionDao.resolve(id, at: now);

      final today = await db.intentionDao.watchToday(dayStart, dayEnd).first;
      expect(today, hasLength(1));
      expect(today.single.isResolved, isTrue);
    });

    test('drops promises resolved on an earlier day', () async {
      final id = await db.intentionDao.capture(
        sample(content: 'done yesterday', reminderAt: DateTime(2026, 3, 3, 9)),
      );
      await db.intentionDao.resolve(id, at: DateTime(2026, 3, 3, 21));

      final today = await db.intentionDao
          .watchToday(
            WeekProjection.startOfDay(now),
            WeekProjection.endOfDay(now),
          )
          .first;
      expect(today, isEmpty);
    });
  });

  group('scheduling queries', () {
    test('dueAt returns only pending promises whose time has come', () async {
      await db.intentionDao.capture(
        sample(
          content: 'due',
          reminderAt: now.subtract(const Duration(minutes: 5)),
        ),
      );
      await db.intentionDao.capture(
        sample(content: 'later', reminderAt: now.add(const Duration(hours: 5))),
      );
      final resolvedId = await db.intentionDao.capture(
        sample(
          content: 'already done',
          reminderAt: now.subtract(const Duration(hours: 1)),
        ),
      );
      await db.intentionDao.resolve(resolvedId, at: now);

      final due = await db.intentionDao.dueAt(now);
      expect(due.map((i) => i.title), <String>['due']);
    });

    test('nextScheduled finds the soonest future reminder', () async {
      await db.intentionDao.capture(
        sample(content: 'far', reminderAt: now.add(const Duration(days: 2))),
      );
      await db.intentionDao.capture(
        sample(content: 'near', reminderAt: now.add(const Duration(hours: 1))),
      );
      expect((await db.intentionDao.nextScheduled(now))!.title, 'near');
    });
  });

  group('event log', () {
    test(
      'grouped counts feed the XP projection without streaming the log',
      () async {
        final first = await db.intentionDao.capture(sample());
        await db.intentionDao.capture(sample(content: 'second'));
        await db.intentionDao.resolve(first, at: now);

        final counts = await db.intentionDao.watchEventCounts().first;
        expect(counts[IntentionEventType.captured], 2);
        expect(counts[IntentionEventType.resolved], 1);
      },
    );

    test('deleting a promise removes its history too (PRD 3.5)', () async {
      final id = await db.intentionDao.capture(sample());
      await db.intentionDao.resolve(id, at: now);
      await db.intentionDao.deleteIntention(id);

      expect(await db.intentionDao.findById(id), isNull);
      expect(await db.intentionDao.watchEventsFor(id).first, isEmpty);
      // The FTS index must forget it as well.
      expect(await db.intentionDao.search('sarah'), isEmpty);
    });
  });

  test('watchToday emits again when a promise is resolved', () async {
    final id = await db.intentionDao.capture(sample());
    final stream = db.intentionDao.watchToday(
      WeekProjection.startOfDay(now),
      WeekProjection.endOfDay(now),
    );
    final emissions = <bool>[];
    final subscription = stream.listen(
      (items) => emissions.add(items.single.isResolved),
    );
    await Future<void>.delayed(Duration.zero);
    await db.intentionDao.resolve(id, at: now);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await subscription.cancel();

    expect(emissions.first, isFalse);
    expect(emissions.last, isTrue);
  });
}
