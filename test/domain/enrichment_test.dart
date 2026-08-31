import 'package:cya/domain/entities/intention.dart';
import 'package:cya/domain/enums/promise_category.dart';
import 'package:cya/domain/services/enrichment.dart';
import 'package:cya/domain/services/reminder_scheduler.dart';
import 'package:cya/domain/usecases/enrich_intention.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/drift_intention_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A Wednesday, mid-afternoon — far enough from every boundary that a
  // failure means a real bug rather than an edge case in the fixture.
  final capturedAt = DateTime(2026, 3, 4, 15, 30);

  group('categorization', () {
    void expectCategory(String content, PromiseCategory? expected) {
      expect(
        EnrichmentService.analyze(content, capturedAt).category,
        expected?.wire,
        reason: content,
      );
    }

    test('reads the verb, not the noun', () {
      expectCategory('Reply to Sarah about Saturday', PromiseCategory.reply);
      expectCategory('Read the Impeller paper', PromiseCategory.read);
      expectCategory('Watch the keynote', PromiseCategory.watch);
      expectCategory('Buy an HDMI cable', PromiseCategory.buy);
      expectCategory('Review PR #128', PromiseCategory.work);
      expectCategory('Book the dentist', PromiseCategory.errand);
      expectCategory(
        'Idea: a garden that grows from kept promises',
        PromiseCategory.idea,
      );
    });

    test('a stronger signal wins outright', () {
      // Both "buy" and "read" appear; buying is what you actually do.
      expectCategory(
        'Buy the book everyone keeps reading',
        PromiseCategory.buy,
      );
    });

    test('a bare link is something to look at later', () {
      expectCategory(
        'https://docs.flutter.dev/perf/impeller',
        PromiseCategory.read,
      );
    });

    test('guesses nothing rather than guessing wrong', () {
      expectCategory('Saturday', null);
      expectCategory('   ', null);
    });

    test('recognises the domain, not just the word', () {
      expectCategory('https://youtu.be/abc123', PromiseCategory.watch);
      expectCategory('https://arxiv.org/abs/1706.03762', PromiseCategory.read);
    });
  });

  group('deadline extraction', () {
    DateTime? deadlineOf(String content) =>
        EnrichmentService.analyze(content, capturedAt).deadline;

    test('resolves named days against the capture time', () {
      expect(deadlineOf('Call mum tonight'), DateTime(2026, 3, 4, 20));
      expect(deadlineOf('Reply tomorrow'), DateTime(2026, 3, 5, 9));
      // Wednesday → the coming Friday.
      expect(deadlineOf('Send it on Friday'), DateTime(2026, 3, 6, 9));
      expect(deadlineOf('Fix it this weekend'), DateTime(2026, 3, 7, 10));
    });

    test('a named day already past this week means next week', () {
      // Captured on a Wednesday: "Tuesday" is six days away, not yesterday.
      expect(deadlineOf('Ping them Tuesday'), DateTime(2026, 3, 10, 9));
    });

    test('applies a written clock time to the resolved day', () {
      expect(deadlineOf('Call mum tomorrow at 7pm'), DateTime(2026, 3, 5, 19));
      expect(
        deadlineOf('Standup tomorrow at 9:30 am'),
        DateTime(2026, 3, 5, 9, 30),
      );
      expect(deadlineOf('Deploy tomorrow at 19:00'), DateTime(2026, 3, 5, 19));
    });

    test('a bare time lands today if it is still ahead, tomorrow if not', () {
      // 15:30 now; "at 8" reads as 20:00 tonight.
      expect(deadlineOf('Call her at 8'), DateTime(2026, 3, 4, 20));
      // 09:00 has already gone by.
      expect(deadlineOf('Call her at 9 am'), DateTime(2026, 3, 5, 9));
    });

    test('does not match a day name inside another word', () {
      // "satisfied" contains "sat"; "sunscreen" contains "sun".
      expect(deadlineOf('Make sure the client is satisfied'), isNull);
      expect(deadlineOf('Pack sunscreen'), isNull);
    });

    test('finds nothing rather than something wrong', () {
      expect(deadlineOf('Reply to Sarah'), isNull);
      expect(deadlineOf('Buy an HDMI cable'), isNull);
      // 31:00 is not a time.
      expect(deadlineOf('Meet at 31'), isNull);
    });
  });

  group('EnrichIntention', () {
    late CyaDatabase db;
    late DriftIntentionRepository repository;
    late _RecordingScheduler scheduler;
    final now = DateTime(2026, 3, 4, 16);

    setUp(() {
      db = CyaDatabase.memory();
      repository = DriftIntentionRepository(db.intentionDao);
      scheduler = _RecordingScheduler();
    });
    tearDown(() => db.close());

    Future<int> capture(
      String content, {
      DateTime? reminderAt,
      String? category,
    }) async {
      final id = await db.intentionDao.capture(
        NewIntention(
          sourceApp: 'Messenger',
          rawContent: content,
          capturedAt: capturedAt,
          reminderAt: reminderAt ?? DateTime(2026, 3, 4, 20),
        ),
      );
      if (category != null) {
        await db.intentionDao.updateCategory(id, category, capturedAt);
      }
      return id;
    }

    test('fills in a missing category and logs the edit', () async {
      final id = await capture('Buy an HDMI cable');

      final changed = await EnrichIntention(
        repository,
        () => now,
        scheduler,
      ).run(await repository.needingEnrichment(limit: 10));

      expect(changed, 1);
      final promise = await db.intentionDao.findById(id);
      expect(promise!.category, PromiseCategory.buy.wire);

      // Every mutation carries its event (PRD §7.1) — enrichment included.
      final events = await db.intentionDao.watchEventsFor(id).first;
      expect(events.map((e) => e.metadata).join(), contains('"change"'));
    });

    test('never overwrites a category the user chose', () async {
      final id = await capture(
        'Buy an HDMI cable',
        category: PromiseCategory.idea.wire,
      );

      await EnrichIntention(
        repository,
        () => now,
        scheduler,
      ).run(await repository.needingEnrichment(limit: 10));

      final promise = await db.intentionDao.findById(id);
      expect(promise!.category, PromiseCategory.idea.wire);
    });

    test('moves an untouched reminder to a deadline the user wrote', () async {
      final id = await capture('Call mum tomorrow at 7pm');

      await EnrichIntention(
        repository,
        () => now,
        scheduler,
      ).run(await repository.needingEnrichment(limit: 10));

      final promise = await db.intentionDao.findById(id);
      expect(promise!.extractedDeadline, DateTime(2026, 3, 5, 19));
      expect(promise.reminderAt, DateTime(2026, 3, 5, 19));
    });

    test('re-arms the alarm whenever it moves the reminder', () async {
      final id = await capture('Call mum tomorrow at 7pm');

      await EnrichIntention(
        repository,
        () => now,
        scheduler,
      ).run(await repository.needingEnrichment(limit: 10));

      // The store and AlarmManager must agree about when this comes back —
      // the alarm is the half the user actually experiences.
      expect(scheduler.scheduled, <(int, DateTime)>[
        (id, DateTime(2026, 3, 5, 19)),
      ]);
    });

    test('records the finding but leaves a snoozed reminder alone', () async {
      final id = await capture('Call mum tomorrow at 7pm');
      await db.intentionDao.snooze(
        id,
        until: DateTime(2026, 3, 6, 12),
        at: now,
      );

      await EnrichIntention(
        repository,
        () => now,
        scheduler,
      ).run(await repository.needingEnrichment(limit: 10));

      final promise = await db.intentionDao.findById(id);
      // The finding is recorded...
      expect(promise!.extractedDeadline, DateTime(2026, 3, 5, 19));
      // ...but the time the user chose stands, and no alarm is touched.
      expect(promise.reminderAt, DateTime(2026, 3, 6, 12));
      expect(scheduler.scheduled, isEmpty);
    });

    test('is idempotent — a second pass finds nothing to do', () async {
      await capture('Buy an HDMI cable tomorrow at 7pm');
      final enrich = EnrichIntention(repository, () => now, scheduler);

      expect(
        await enrich.run(await repository.needingEnrichment(limit: 10)),
        1,
      );
      expect(
        await enrich.run(await repository.needingEnrichment(limit: 10)),
        0,
      );
    });
  });
}

/// Records what was scheduled, so a test can assert the store and the alarm
/// were kept in step.
class _RecordingScheduler implements ReminderScheduler {
  final List<(int, DateTime)> scheduled = <(int, DateTime)>[];
  final List<int> cancelled = <int>[];

  @override
  Future<void> schedule(int intentionId, DateTime at) async =>
      scheduled.add((intentionId, at));

  @override
  Future<void> cancel(int intentionId) async => cancelled.add(intentionId);
}
