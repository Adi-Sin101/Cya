import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../domain/entities/intention.dart';
import '../../domain/entities/intention_event.dart';
import '../../domain/enums/intention_event_type.dart';
import '../../domain/models/garden_summary.dart';
import '../../domain/models/user_level.dart';
import '../../domain/models/week_stats.dart';
import '../../domain/projections/week_projection.dart';
import '../../domain/projections/xp_projection.dart';

/// Reactive views over the local store (PRD §3.3).
///
/// Each provider watches the **narrowest** query that answers its question, so
/// a write only rebuilds the sections it actually affects (PRD §9.1).

/// Today's Promises — due by end of today, plus what was resolved today.
final todayIntentionsProvider = StreamProvider.autoDispose<List<Intention>>((
  ref,
) {
  final now = ref.watch(clockProvider)();
  return ref
      .watch(intentionRepositoryProvider)
      .watchToday(
        dayStart: WeekProjection.startOfDay(now),
        dayEnd: WeekProjection.endOfDay(now),
      );
});

/// Every promise that has not been archived (the Promises tab).
final allIntentionsProvider = StreamProvider.autoDispose<List<Intention>>(
  (ref) => ref.watch(intentionRepositoryProvider).watchAllActive(),
);

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
