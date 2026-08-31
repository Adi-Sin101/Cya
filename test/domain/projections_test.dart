import 'package:cya/domain/entities/intention_event.dart';
import 'package:cya/domain/enums/intention_event_type.dart';
import 'package:cya/domain/projections/week_projection.dart';
import 'package:cya/domain/projections/xp_projection.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gamification and metrics must be *projections* over the event log
/// (PRD §6.6/§11) — these tests pin that they are pure and recomputable.
void main() {
  group('XpProjection', () {
    test('weights resolution above capture', () {
      expect(
        XpProjection.xpPerResolution,
        greaterThan(XpProjection.xpPerCapture),
      );
    });

    test('total XP is a pure function of event counts', () {
      final counts = <IntentionEventType, int>{
        IntentionEventType.captured: 10,
        IntentionEventType.resolved: 4,
        IntentionEventType.snoozed: 7, // earns nothing
      };
      expect(XpProjection.totalXp(counts), 10 * 10 + 4 * 25);
    });

    test('a fresh account is level 1 with no progress', () {
      final level = XpProjection.levelFor(0);
      expect(level.level, 1);
      expect(level.xp, 0);
      expect(level.xpTarget, 250);
      expect(level.progress, 0);
    });

    test('levels advance on the 250 x level curve', () {
      expect(XpProjection.levelFor(249).level, 1);
      expect(XpProjection.levelFor(250).level, 2);
      // 250 + 500 = 750 to reach level 3.
      expect(XpProjection.levelFor(749).level, 2);
      expect(XpProjection.levelFor(750).level, 3);
    });

    test('progress inside a level is the remainder, not the total', () {
      final level = XpProjection.levelFor(250 + 120);
      expect(level.level, 2);
      expect(level.xp, 120);
      expect(level.xpTarget, 500);
    });

    test('level 12 carries the design mockup title and 3,000 XP band', () {
      // Cumulative XP to *reach* level 12 = 250 * (1+2+...+11) = 16,500.
      final level = XpProjection.levelFor(16500);
      expect(level.level, 12);
      expect(level.xpTarget, 3000);
      expect(level.title, 'Future Builder');
    });

    test('negative XP cannot happen and degrades to level 1', () {
      expect(XpProjection.levelFor(-40).level, 1);
    });
  });

  group('WeekProjection', () {
    // Wednesday 2026-03-04; the week starts Monday 2026-03-02.
    final now = DateTime(2026, 3, 4, 18);

    IntentionEvent event(IntentionEventType type, DateTime at, [int id = 1]) =>
        IntentionEvent(id: id, intentionId: id, type: type, occurredAt: at);

    test('the week starts on Monday', () {
      expect(WeekProjection.startOfWeek(now), DateTime(2026, 3, 2));
      // A Sunday belongs to the week that started six days earlier.
      expect(
        WeekProjection.startOfWeek(DateTime(2026, 3, 8, 23)),
        DateTime(2026, 3, 2),
      );
    });

    test('counts captures and completions, ignoring other event types', () {
      final events = <IntentionEvent>[
        event(IntentionEventType.captured, DateTime(2026, 3, 2, 9)),
        event(IntentionEventType.captured, DateTime(2026, 3, 3, 9)),
        event(IntentionEventType.resolved, DateTime(2026, 3, 3, 20)),
        event(IntentionEventType.snoozed, DateTime(2026, 3, 4, 8)),
        event(IntentionEventType.resurfaced, DateTime(2026, 3, 4, 8)),
      ];
      final stats = WeekProjection.stats(events, now);
      expect(stats.captured, 2);
      expect(stats.completed, 1);
      expect(stats.successRate, 0.5);
    });

    test('events from before the week are excluded', () {
      final events = <IntentionEvent>[
        event(IntentionEventType.captured, DateTime(2026, 2, 27, 9)),
        event(IntentionEventType.captured, DateTime(2026, 3, 3, 9)),
      ];
      expect(WeekProjection.stats(events, now).captured, 1);
    });

    test('the trend line has one normalized point per weekday', () {
      final events = <IntentionEvent>[
        event(IntentionEventType.resolved, DateTime(2026, 3, 2, 10)),
        event(IntentionEventType.resolved, DateTime(2026, 3, 4, 10)),
        event(IntentionEventType.resolved, DateTime(2026, 3, 4, 11)),
      ];
      final trend = WeekProjection.stats(events, now).trend;
      expect(trend, hasLength(7));
      expect(trend[0], 0.5); // Monday: 1 of the busiest day's 2
      expect(trend[2], 1.0); // Wednesday: the peak
      expect(trend[6], 0.0);
    });

    test('an empty week is flat, not a division by zero', () {
      final stats = WeekProjection.stats(const <IntentionEvent>[], now);
      expect(stats.successRate, 0);
      expect(stats.trend.every((point) => point == 0), isTrue);
    });

    test('garden growth counts this week resolutions only', () {
      final events = <IntentionEvent>[
        event(IntentionEventType.resolved, DateTime(2026, 2, 25, 10)),
        event(IntentionEventType.resolved, DateTime(2026, 3, 3, 10)),
        event(IntentionEventType.resolved, DateTime(2026, 3, 4, 10)),
        event(IntentionEventType.captured, DateTime(2026, 3, 4, 10)),
      ];
      expect(WeekProjection.garden(events, now).newGrowthsThisWeek, 2);
    });
  });
}
