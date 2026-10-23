import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import '../../core/di/providers.dart';
import '../../data/repositories/routine_repository.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/routine.dart';
import '../../domain/entities/focus_timer.dart';
import '../../data/repositories/focus_timer_repository.dart';
import 'memory_providers.dart';

final focusTimerRepositoryProvider = Provider(
  (ref) => FocusTimerRepository(ref.watch(databaseProvider)),
);
final focusTimerRawProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(preferenceDaoProvider).watch(focusTimerKey),
);
final focusTimerSnapshotProvider =
    FutureProvider.autoDispose<FocusTimerSnapshot?>((ref) {
      ref.watch(focusTimerRawProvider);
      ref.watch(focusPriorityProvider);
      return ref.watch(focusTimerRepositoryProvider).load();
    });

final routineRepositoryProvider = Provider(
  (ref) => RoutineRepository(ref.watch(databaseProvider)),
);
final routinesProvider = StreamProvider.autoDispose.family<List<Routine>, bool>(
  (ref, removed) =>
      ref.watch(routineRepositoryProvider).watch(includeRemoved: removed),
);
final dayRoutinesProvider = StreamProvider.autoDispose
    .family<List<RoutineOccurrence>, String>(
      (ref, day) =>
          ref.watch(routineRepositoryProvider).occurrences(parseLocalDay(day)),
    );
final earlierRoutinesProvider = StreamProvider.autoDispose
    .family<List<RoutineOccurrence>, String>(
      (ref, day) => ref
          .watch(routineRepositoryProvider)
          .occurrences(parseLocalDay(day), earlierOpen: true),
    );
final routineOccurrenceEventsProvider = StreamProvider.autoDispose.family(
  (ref, String id) =>
      ref.watch(routineRepositoryProvider).occurrenceHistory(id),
);
final routineVersionsProvider = StreamProvider.autoDispose.family((
  ref,
  String id,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.routineRevisions)
        ..where((r) => r.routineId.equals(id))
        ..orderBy([(r) => OrderingTerm.desc(r.revision)]))
      .watch();
});
final reviewActivityProvider = StreamProvider.autoDispose<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db
      .customSelect(
        '''SELECT (SELECT COUNT(*) FROM routine_occurrence_events) + (SELECT COUNT(*) FROM intention_events)
    + (SELECT COUNT(*) FROM memory_events) AS count''',
        readsFrom: {
          db.routineOccurrenceEvents,
          db.intentionEvents,
          db.memoryEvents,
        },
      )
      .watch()
      .map((rows) => rows.single.read<int>('count'));
});
typedef ReviewFilter = ({String day, String period});
final reviewFactsProvider = FutureProvider.autoDispose
    .family<LocalReviewFacts, ReviewFilter>((ref, filter) {
      ref.watch(reviewActivityProvider);
      return ref
          .watch(routineRepositoryProvider)
          .facts(parseLocalDay(filter.day), filter.period);
    });
final reviewNoteProvider = FutureProvider.autoDispose
    .family<Memory?, ReviewFilter>((ref, filter) {
      ref.watch(reviewActivityProvider);
      return ref
          .watch(routineRepositoryProvider)
          .reviewNote(parseLocalDay(filter.day), filter.period);
    });
