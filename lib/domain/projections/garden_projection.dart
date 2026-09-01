import '../entities/intention_event.dart';
import '../enums/intention_event_type.dart';
import 'week_projection.dart';

/// One plant in the Memory Garden — a promise the user kept (PRD §6.6).
class GardenPlant {
  const GardenPlant({
    required this.intentionId,
    required this.resolvedAt,
    required this.species,
    required this.growth,
  });

  final int intentionId;
  final DateTime resolvedAt;

  /// Which plant this is. Derived from the intention id, so a promise always
  /// grows into the *same* plant — the garden is a memory, not a slideshow.
  final int species;

  /// How far along it is, `0..1`, from how long ago it was resolved. Plants
  /// keep growing for a week after the promise was kept.
  final double growth;
}

/// A week's worth of growth — the garden is laid out in weekly beds so progress
/// reads as a history rather than a pile.
class GardenBed {
  const GardenBed({required this.weekStart, required this.plants});

  final DateTime weekStart;
  final List<GardenPlant> plants;
}

/// Everything the Garden screen draws.
class GardenScene {
  const GardenScene({
    required this.beds,
    required this.totalGrowths,
    required this.thisWeekGrowths,
    required this.streakDays,
    this.totalCaptured = 0,
  });

  static const GardenScene empty = GardenScene(
    beds: <GardenBed>[],
    totalGrowths: 0,
    thisWeekGrowths: 0,
    streakDays: 0,
  );

  /// Oldest bed first, so the newest growth sits at the end of the scroll.
  final List<GardenBed> beds;
  final int totalGrowths;
  final int thisWeekGrowths;

  /// Every promise ever captured — the denominator of [keptRate].
  final int totalCaptured;

  /// Consecutive days, ending today or yesterday, with at least one promise
  /// kept.
  ///
  /// **No longer surfaced (ADR-011.)** A streak is a daily-habit mechanic, and
  /// Cya! is a trusted utility: someone who captures on Monday, keeps
  /// everything on Tuesday and has a calm Wednesday used the product perfectly
  /// and would be shown a zero. Kept here because it is cheap, tested, and the
  /// achievement stats still carry it; [keptRate] is what the Garden shows.
  final int streakDays;

  /// Share of captured promises that were kept, `0..1` — the metric §11 calls
  /// "resolution rate". Unlike a streak it cannot reset, so a quiet week costs
  /// the user nothing. Null until something has been captured.
  double? get keptRate =>
      totalCaptured == 0 ? null : totalGrowths / totalCaptured;

  bool get isEmpty => totalGrowths == 0;
}

/// The Memory Garden, projected from the event log (PRD §6.6, ADR-002).
///
/// Nothing here is stored. Delete the garden, recompute it from the events, and
/// it comes back identical — the same property that makes XP tamper-resistant.
abstract final class GardenProjection {
  const GardenProjection._();

  /// How many distinct plants exist. Enough that a full bed looks like a
  /// meadow rather than a repeated tile, few enough that the garden still
  /// reads as one place rather than a botanical index.
  static const int speciesCount = 8;

  /// A plant reaches full size a week after the promise was kept.
  static const Duration timeToMaturity = Duration(days: 7);

  static GardenScene build(List<IntentionEvent> events, DateTime now) {
    final totalCaptured = events
        .where((event) => event.type == IntentionEventType.captured)
        .length;
    final resolutions =
        events
            .where((event) => event.type == IntentionEventType.resolved)
            .toList()
          ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    // No plants yet, but captures may still exist — the kept-rate has to be
    // able to say "0 of 7", which is honest, rather than nothing at all.
    if (resolutions.isEmpty) {
      return GardenScene(
        beds: const <GardenBed>[],
        totalGrowths: 0,
        thisWeekGrowths: 0,
        streakDays: 0,
        totalCaptured: totalCaptured,
      );
    }

    final byWeek = <DateTime, List<GardenPlant>>{};
    for (final event in resolutions) {
      final weekStart = WeekProjection.startOfWeek(event.occurredAt);
      byWeek
          .putIfAbsent(weekStart, () => <GardenPlant>[])
          .add(
            GardenPlant(
              intentionId: event.intentionId,
              resolvedAt: event.occurredAt,
              species: event.intentionId % speciesCount,
              growth: _growthAt(event.occurredAt, now),
            ),
          );
    }

    final weekStarts = byWeek.keys.toList()..sort();
    final thisWeek = WeekProjection.startOfWeek(now);

    return GardenScene(
      beds: <GardenBed>[
        for (final weekStart in weekStarts)
          GardenBed(weekStart: weekStart, plants: byWeek[weekStart]!),
      ],
      totalGrowths: resolutions.length,
      thisWeekGrowths: byWeek[thisWeek]?.length ?? 0,
      streakDays: streak(resolutions, now),
      totalCaptured: totalCaptured,
    );
  }

  /// Consecutive days with a kept promise, counting back from today (or from
  /// yesterday, if today has none yet).
  static int streak(List<IntentionEvent> resolutions, DateTime now) {
    if (resolutions.isEmpty) return 0;
    final days = <DateTime>{
      for (final event in resolutions)
        if (event.type == IntentionEventType.resolved)
          DateTime(
            event.occurredAt.year,
            event.occurredAt.month,
            event.occurredAt.day,
          ),
    };
    if (days.isEmpty) return 0;

    final today = DateTime(now.year, now.month, now.day);
    var cursor = days.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;

    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return count;
  }

  static double _growthAt(DateTime resolvedAt, DateTime now) {
    final age = now.difference(resolvedAt);
    if (age.isNegative) return _seedlingGrowth;
    final progress = age.inMinutes / timeToMaturity.inMinutes;
    final growth = _seedlingGrowth + (1 - _seedlingGrowth) * progress;
    return growth.clamp(_seedlingGrowth, 1).toDouble();
  }

  /// A brand-new plant is already visible — a kept promise should show up the
  /// moment it is kept, not a day later.
  static const double _seedlingGrowth = 0.45;
}
