import '../entities/intention.dart';
import '../entities/intention_event.dart';
import '../enums/intention_event_type.dart';

/// The domain's view of the local store (PRD §5.3 — `domain/` depends on no
/// framework and no database).
///
/// Mutations take an explicit `at` timestamp instead of reading the clock
/// themselves: the caller (a use-case) owns time, which keeps every rule here
/// testable without waiting for one.
abstract interface class IntentionRepository {
  /// Promises due by [dayEnd], plus what was resolved since [dayStart].
  Stream<List<Intention>> watchToday({
    required DateTime dayStart,
    required DateTime dayEnd,
  });

  Stream<List<Intention>> watchAllActive();

  Stream<Intention?> watchById(int id);

  Stream<List<IntentionEvent>> watchEventsSince(DateTime since);

  Stream<List<IntentionEvent>> watchEventsFor(int intentionId);

  /// Lifetime counts per event type — the narrow aggregate XP projects from.
  Stream<Map<IntentionEventType, int>> watchEventCounts();

  /// Every kept promise, oldest first — what the Memory Garden grows from.
  Stream<List<IntentionEvent>> watchResolutions();

  /// Kept promises that carried a link, and that came from a messaging app.
  Stream<({int links, int conversations})> watchResolvedBreakdown();

  Future<List<Intention>> search(String query);

  Future<Intention?> findById(int id);

  /// Promises whose reminder is due at or before [instant].
  Future<List<Intention>> dueAt(DateTime instant);

  /// The next promise needing an alarm after [after].
  Future<Intention?> nextScheduled(DateTime after);

  /// Promises whose reminder came and went without ever being shown —
  /// evidence that alarms are being dropped (PRD §12).
  Future<List<Intention>> missedReminders(DateTime now, {Duration grace});

  Future<int> count();

  Future<int> capture(NewIntention intention);

  Future<void> resolve(int id, {required DateTime at});

  Future<void> reopen(int id, {required DateTime at});

  Future<void> snooze(int id, {required DateTime until, required DateTime at});

  Future<void> archive(int id, {required DateTime at});

  Future<void> markResurfaced(int id, {required DateTime at, String? tier});

  Future<void> updateReminder(
    int id, {
    required DateTime? reminderAt,
    required DateTime at,
  });

  Future<void> updateCategory(
    int id, {
    required String? category,
    required DateTime at,
  });

  Future<void> updateContent(
    int id, {
    required String rawContent,
    required DateTime at,
  });

  /// Permanent deletion, including the promise's event log (PRD §3.5).
  Future<void> deleteIntention(int id);
}
