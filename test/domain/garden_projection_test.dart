import 'package:cya/domain/entities/intention_event.dart';
import 'package:cya/domain/enums/intention_event_type.dart';
import 'package:cya/domain/projections/achievement_projection.dart';
import 'package:cya/domain/projections/garden_projection.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Memory Garden and the badges are projections over the event log
/// (PRD §6.6, ADR-002) — recomputable and impossible to hold state the events
/// do not justify.
void main() {
  // Wednesday 2026-03-04; the week starts Monday 2026-03-02.
  final now = DateTime(2026, 3, 4, 18);

  IntentionEvent resolved(int intentionId, DateTime at) => IntentionEvent(
    id: intentionId,
    intentionId: intentionId,
    type: IntentionEventType.resolved,
    occurredAt: at,
  );

  group('GardenProjection', () {
    test('an empty log grows nothing', () {
      final scene = GardenProjection.build(const <IntentionEvent>[], now);
      expect(scene.isEmpty, isTrue);
      expect(scene.beds, isEmpty);
      expect(scene.streakDays, 0);
    });

    // ADR-011: the Garden shows a kept-rate instead of a streak, because a
    // streak resets on a calm week and Cya! is a trusted utility, not a habit.
    group('kept-rate', () {
      IntentionEvent captured(int intentionId, DateTime at) => IntentionEvent(
        id: 1000 + intentionId,
        intentionId: intentionId,
        type: IntentionEventType.captured,
        occurredAt: at,
      );

      test('is null until something has been captured', () {
        expect(
          GardenProjection.build(const <IntentionEvent>[], now).keptRate,
          isNull,
        );
      });

      test('is 0 when promises were captured but none kept', () {
        final scene = GardenProjection.build(<IntentionEvent>[
          for (var i = 1; i <= 7; i++) captured(i, DateTime(2026, 3, 3, 9)),
        ], now);
        expect(scene.totalCaptured, 7);
        expect(scene.keptRate, 0);
        // No plants, but the rate can still answer honestly.
        expect(scene.isEmpty, isTrue);
      });

      test('is kept over captured', () {
        final scene = GardenProjection.build(<IntentionEvent>[
          for (var i = 1; i <= 4; i++) captured(i, DateTime(2026, 3, 2, 9)),
          resolved(1, DateTime(2026, 3, 3, 10)),
          resolved(2, DateTime(2026, 3, 3, 11)),
          resolved(3, DateTime(2026, 3, 4, 9)),
        ], now);
        expect(scene.totalCaptured, 4);
        expect(scene.totalGrowths, 3);
        expect(scene.keptRate, 0.75);
      });

      test(
        'does not reset after a quiet day, unlike the streak it replaced',
        () {
          // Everything captured and kept last week; nothing since.
          final events = <IntentionEvent>[
            captured(1, DateTime(2026, 2, 24, 9)),
            captured(2, DateTime(2026, 2, 24, 9)),
            resolved(1, DateTime(2026, 2, 24, 10)),
            resolved(2, DateTime(2026, 2, 24, 11)),
          ];
          final scene = GardenProjection.build(events, now);
          expect(scene.streakDays, 0, reason: 'the streak is long broken');
          expect(scene.keptRate, 1.0, reason: 'the record still stands');
        },
      );
    });

    test('only kept promises become plants', () {
      final events = <IntentionEvent>[
        resolved(1, DateTime(2026, 3, 3, 10)),
        IntentionEvent(
          id: 2,
          intentionId: 2,
          type: IntentionEventType.captured,
          occurredAt: DateTime(2026, 3, 3, 11),
        ),
        IntentionEvent(
          id: 3,
          intentionId: 3,
          type: IntentionEventType.snoozed,
          occurredAt: DateTime(2026, 3, 3, 12),
        ),
      ];
      final scene = GardenProjection.build(events, now);
      expect(scene.totalGrowths, 1);
      expect(scene.beds.single.plants.single.intentionId, 1);
    });

    test('plants are grouped into weekly beds, oldest first', () {
      final scene = GardenProjection.build(<IntentionEvent>[
        resolved(1, DateTime(2026, 2, 24, 10)), // an earlier week
        resolved(2, DateTime(2026, 3, 3, 10)),
        resolved(3, DateTime(2026, 3, 4, 10)),
      ], now);

      expect(scene.beds, hasLength(2));
      expect(scene.beds.first.weekStart, DateTime(2026, 2, 23));
      expect(scene.beds.last.weekStart, DateTime(2026, 3, 2));
      expect(scene.beds.last.plants, hasLength(2));
      expect(scene.thisWeekGrowths, 2);
    });

    test('a promise always grows into the same plant', () {
      final first = GardenProjection.build(<IntentionEvent>[
        resolved(7, DateTime(2026, 3, 3, 10)),
      ], now).beds.single.plants.single;
      final again = GardenProjection.build(<IntentionEvent>[
        resolved(7, DateTime(2026, 3, 3, 10)),
      ], now.add(const Duration(days: 3))).beds.single.plants.single;

      expect(first.species, again.species);
    });

    test('a plant is visible immediately and matures over a week', () {
      final fresh = GardenProjection.build(<IntentionEvent>[
        resolved(1, now),
      ], now).beds.single.plants.single;
      final mature = GardenProjection.build(<IntentionEvent>[
        resolved(1, now.subtract(const Duration(days: 8))),
      ], now).beds.single.plants.single;
      final halfway = GardenProjection.build(<IntentionEvent>[
        resolved(1, now.subtract(const Duration(days: 3))),
      ], now).beds.single.plants.single;

      expect(fresh.growth, greaterThan(0));
      expect(fresh.growth, lessThan(halfway.growth));
      expect(halfway.growth, lessThan(mature.growth));
      expect(mature.growth, 1);
    });

    group('streak', () {
      test('counts consecutive days ending today', () {
        final scene = GardenProjection.build(<IntentionEvent>[
          resolved(1, DateTime(2026, 3, 2, 9)),
          resolved(2, DateTime(2026, 3, 3, 9)),
          resolved(3, DateTime(2026, 3, 4, 9)),
        ], now);
        expect(scene.streakDays, 3);
      });

      test('several promises in one day are still one day', () {
        final scene = GardenProjection.build(<IntentionEvent>[
          resolved(1, DateTime(2026, 3, 4, 9)),
          resolved(2, DateTime(2026, 3, 4, 14)),
        ], now);
        expect(scene.streakDays, 1);
      });

      test('survives a today with nothing kept yet', () {
        // The day is not over — a streak should not break before it is.
        final scene = GardenProjection.build(<IntentionEvent>[
          resolved(1, DateTime(2026, 3, 2, 9)),
          resolved(2, DateTime(2026, 3, 3, 9)),
        ], now);
        expect(scene.streakDays, 2);
      });

      test('breaks after a missed day', () {
        final scene = GardenProjection.build(<IntentionEvent>[
          resolved(1, DateTime(2026, 2, 28, 9)),
          resolved(2, DateTime(2026, 3, 3, 9)),
        ], now);
        expect(scene.streakDays, 1);
      });

      test('is zero once two days have passed with nothing', () {
        final scene = GardenProjection.build(<IntentionEvent>[
          resolved(1, DateTime(2026, 3, 1, 9)),
        ], now);
        expect(scene.streakDays, 0);
      });
    });
  });

  group('AchievementProjection', () {
    test('a fresh account has everything locked', () {
      final badges = AchievementProjection.evaluate(const AchievementStats());
      expect(badges.every((a) => !a.isUnlocked), isTrue);
      expect(badges.first.id, 'first_step');
    });

    test('the first capture unlocks First Step and nothing else', () {
      final badges = AchievementProjection.evaluate(
        const AchievementStats(captured: 1),
      );
      expect(
        AchievementProjection.unlocked(const AchievementStats(captured: 1)),
        hasLength(1),
      );
      expect(badges.first.isUnlocked, isTrue);
    });

    test('locked badges report real progress, not a blank', () {
      final badges = AchievementProjection.evaluate(
        const AchievementStats(captured: 3, resolved: 25),
      );
      final neverLost = badges.firstWhere((a) => a.id == 'never_lost');
      expect(neverLost.progress, 25);
      expect(neverLost.target, 100);
      expect(neverLost.fraction, 0.25);
      expect(neverLost.isUnlocked, isFalse);
    });

    test('flavour badges count their own kind of promise', () {
      final stats = const AchievementStats(
        captured: 200,
        resolved: 120,
        linksResolved: 50,
        conversationsResolved: 20,
      );
      final unlocked = AchievementProjection.unlocked(
        stats,
      ).map((a) => a.id).toSet();
      expect(unlocked, contains('reader')); // 50 links read
      expect(unlocked, contains('never_lost')); // 100 kept
      expect(unlocked, isNot(contains('communicator'))); // only 20 replies
      expect(unlocked, isNot(contains('future_you')));
    });

    test('newlyUnlocked reports only what a change earned', () {
      const before = AchievementStats(captured: 100, resolved: 99);
      const after = AchievementStats(captured: 100, resolved: 100);
      final earned = AchievementProjection.newlyUnlocked(before, after);
      expect(earned.map((a) => a.id), <String>['never_lost']);
    });

    test('progress never exceeds its target', () {
      final badges = AchievementProjection.evaluate(
        const AchievementStats(captured: 9999, resolved: 9999),
      );
      expect(badges.every((a) => a.fraction <= 1), isTrue);
    });
  });
}
