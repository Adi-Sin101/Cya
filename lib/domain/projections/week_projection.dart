import '../entities/intention_event.dart';
import '../enums/intention_event_type.dart';
import '../models/garden_summary.dart';
import '../models/week_stats.dart';

/// This-week metrics and Memory Garden growth, projected from the event log
/// (PRD §6.6, §11). Pure functions: same events in, same numbers out.
abstract final class WeekProjection {
  const WeekProjection._();

  /// Monday 00:00 of the week containing [now] — the week boundary used
  /// everywhere in the app so stats and the garden always agree.
  static DateTime startOfWeek(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - DateTime.monday));
  }

  static DateTime startOfDay(DateTime now) =>
      DateTime(now.year, now.month, now.day);

  static DateTime endOfDay(DateTime now) =>
      DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

  /// Captured / completed / success rate + a 7-point trend line (Mon→Sun) of
  /// resolutions per day, normalized against the busiest day.
  static WeekStats stats(List<IntentionEvent> weekEvents, DateTime now) {
    final weekStart = startOfWeek(now);
    var captured = 0;
    var completed = 0;
    final perDay = List<int>.filled(7, 0);

    for (final event in weekEvents) {
      if (event.occurredAt.isBefore(weekStart)) continue;
      switch (event.type) {
        case IntentionEventType.captured:
          captured++;
        case IntentionEventType.resolved:
          completed++;
          final dayIndex = event.occurredAt.difference(weekStart).inDays;
          if (dayIndex >= 0 && dayIndex < 7) perDay[dayIndex]++;
        case IntentionEventType.snoozed:
        case IntentionEventType.resurfaced:
        case IntentionEventType.archived:
        case IntentionEventType.edited:
          break;
      }
    }

    final peak = perDay.fold<int>(0, (max, value) => value > max ? value : max);
    final trend = <double>[
      for (final value in perDay) peak == 0 ? 0 : value / peak,
    ];
    return WeekStats(captured: captured, completed: completed, trend: trend);
  }

  /// A resolved promise is a new growth in the Memory Garden (PRD §6.6).
  static GardenSummary garden(List<IntentionEvent> weekEvents, DateTime now) {
    final weekStart = startOfWeek(now);
    final growths = weekEvents
        .where(
          (event) =>
              event.type == IntentionEventType.resolved &&
              !event.occurredAt.isBefore(weekStart),
        )
        .length;
    return GardenSummary(newGrowthsThisWeek: growths);
  }
}
