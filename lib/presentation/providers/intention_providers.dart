import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../domain/entities/intention.dart';
import '../../domain/entities/intention_event.dart';
import '../../domain/enums/intention_event_type.dart';
import '../../domain/models/garden_summary.dart';
import '../../domain/models/user_level.dart';
import '../../domain/models/week_stats.dart';
import '../../domain/policies/aging_policy.dart';
import '../../domain/projections/achievement_projection.dart';
import '../../domain/projections/garden_projection.dart';
import '../../domain/projections/week_projection.dart';
import '../../domain/projections/xp_projection.dart';
import 'today_provider.dart';

/// Reactive views over the local store (PRD §3.3).
///
/// Each provider watches the **narrowest** query that answers its question, so
/// a write only rebuilds the sections it actually affects (PRD §9.1).

/// Today's Promises — due by end of today, plus what was resolved today.
///
/// The day boundary comes from [todayProvider], not from a one-off read of the
/// clock, so an app left open across midnight rolls over on its own instead of
/// showing yesterday until something else forces a rebuild.
final todayIntentionsProvider = StreamProvider.autoDispose<List<Intention>>((
  ref,
) {
  final dayStart = ref.watch(todayProvider);
  return ref
      .watch(intentionRepositoryProvider)
      .watchToday(
        dayStart: dayStart,
        dayEnd: WeekProjection.endOfDay(dayStart),
      );
});

/// Every promise that has not been archived (the Promises tab).
final allIntentionsProvider = StreamProvider.autoDispose<List<Intention>>(
  (ref) => ref.watch(intentionRepositoryProvider).watchAllActive(),
);

/// Promises that retired themselves recently (ADR-014).
///
/// A fortnight's worth, not everything ever retired: the digest's offer is
/// "did I get that wrong?", and a list going back years is a graveyard, not a
/// question.
final recentlyRetiredProvider = StreamProvider.autoDispose<List<Intention>>((
  ref,
) {
  final now = ref.watch(clockProvider)();
  return ref
      .watch(intentionRepositoryProvider)
      .watchRetiredSince(
        now.subtract(const Duration(days: 14)),
        AgingPolicy.reason,
      );
});

final intentionByIdProvider = StreamProvider.autoDispose
    .family<Intention?, int>(
      (ref, id) => ref.watch(intentionRepositoryProvider).watchById(id),
    );

final intentionEventsProvider = StreamProvider.autoDispose
    .family<List<IntentionEvent>, int>(
      (ref, id) => ref.watch(intentionRepositoryProvider).watchEventsFor(id),
    );

/// This week's events — the raw material for the week stats and the garden.
final weekEventsProvider = StreamProvider.autoDispose<List<IntentionEvent>>((
  ref,
) {
  final now = ref.watch(clockProvider)();
  return ref
      .watch(intentionRepositoryProvider)
      .watchEventsSince(WeekProjection.startOfWeek(now));
});

final weekStatsProvider = Provider.autoDispose<WeekStats>((ref) {
  final events =
      ref.watch(weekEventsProvider).valueOrNull ?? const <IntentionEvent>[];
  return WeekProjection.stats(events, ref.watch(clockProvider)());
});

final gardenSummaryProvider = Provider.autoDispose<GardenSummary>((ref) {
  final events =
      ref.watch(weekEventsProvider).valueOrNull ?? const <IntentionEvent>[];
  return WeekProjection.garden(events, ref.watch(clockProvider)());
});

/// Lifetime event counts — a single grouped aggregate, not the whole log.
final eventCountsProvider =
    StreamProvider.autoDispose<Map<IntentionEventType, int>>(
      (ref) => ref.watch(intentionRepositoryProvider).watchEventCounts(),
    );

/// XP and level, recomputed from the event log every time it changes (§6.6).
final userLevelProvider = Provider.autoDispose<UserLevel>((ref) {
  final counts =
      ref.watch(eventCountsProvider).valueOrNull ??
      const <IntentionEventType, int>{};
  return XpProjection.fromEventCounts(counts);
});

/// On-device full-text search over captured content (PRD §6.4).
final intentionSearchProvider = FutureProvider.autoDispose
    .family<List<Intention>, String>((ref, query) async {
      if (query.trim().isEmpty) {
        return ref.watch(allIntentionsProvider).valueOrNull ??
            const <Intention>[];
      }
      return ref.watch(intentionRepositoryProvider).search(query);
    });

/// The Memory Garden, grown from every kept promise (PRD §6.6).
final gardenSceneProvider = Provider.autoDispose<GardenScene>((ref) {
  final resolutions =
      ref.watch(_resolutionsProvider).valueOrNull ?? const <IntentionEvent>[];
  return GardenProjection.build(resolutions, ref.watch(clockProvider)());
});

final _resolutionsProvider = StreamProvider.autoDispose<List<IntentionEvent>>(
  (ref) => ref.watch(intentionRepositoryProvider).watchResolutions(),
);

final _resolvedBreakdownProvider =
    StreamProvider.autoDispose<({int links, int conversations})>(
      (ref) => ref.watch(intentionRepositoryProvider).watchResolvedBreakdown(),
    );

/// Everything the badges are decided from — counts plus the current streak.
final achievementStatsProvider = Provider.autoDispose<AchievementStats>((ref) {
  final counts =
      ref.watch(eventCountsProvider).valueOrNull ??
      const <IntentionEventType, int>{};
  final breakdown =
      ref.watch(_resolvedBreakdownProvider).valueOrNull ??
      (links: 0, conversations: 0);
  return AchievementStats(
    captured: counts[IntentionEventType.captured] ?? 0,
    resolved: counts[IntentionEventType.resolved] ?? 0,
    linksResolved: breakdown.links,
    conversationsResolved: breakdown.conversations,
    streakDays: ref.watch(gardenSceneProvider).streakDays,
  );
});

final achievementsProvider = Provider.autoDispose<List<Achievement>>(
  (ref) => AchievementProjection.evaluate(ref.watch(achievementStatsProvider)),
);
