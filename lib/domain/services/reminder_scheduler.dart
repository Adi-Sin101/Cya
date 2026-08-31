/// Scheduling a promise's reminder, as the domain sees it (PRD §5.6).
///
/// The implementation is native (`AlarmManager`), but `domain/` must not know
/// that — so use-cases depend on this interface and stay pure Dart (PRD §5.3).
abstract interface class ReminderScheduler {
  /// Arm (or re-arm) the reminder for [intentionId] at [at].
  Future<void> schedule(int intentionId, DateTime at);

  /// Drop the reminder for [intentionId] — it was resolved, archived or deleted.
  Future<void> cancel(int intentionId);
}

/// Used where there is no scheduler: tests, and platforms whose native side has
/// not landed yet. A promise is still saved; only its alarm is missing, which is
/// exactly what the missed-reminder check surfaces (PRD §12).
class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<void> schedule(int intentionId, DateTime at) async {}

  @override
  Future<void> cancel(int intentionId) async {}
}
