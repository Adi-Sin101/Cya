import '../../core/utils/clock.dart';
import '../policies/aging_policy.dart';
import '../repositories/intention_repository.dart';
import '../services/reminder_scheduler.dart';

/// Retires promises nothing has touched for a month (ADR-014).
///
/// Runs once per app start, after enrichment — never on the capture path, and
/// never on a timer. A sweep is cheap (one indexed query that usually matches
/// nothing) and being a few hours late to retire something is not a defect;
/// the alternative, a background job, would be a whole scheduling surface for a
/// job whose deadline is "eventually".
///
/// Cancelling the alarms is the part that matters. An archived promise with a
/// live `AlarmManager` entry is exactly the silent-loop bug [L-006] taught, and
/// this use-case is where that pairing is enforced rather than remembered.
class RetireStaleIntentions {
  const RetireStaleIntentions(this._repository, this._clock, this._scheduler);

  final IntentionRepository _repository;
  final Clock _clock;
  final ReminderScheduler _scheduler;

  /// Returns how many promises were retired.
  Future<int> run() async {
    final now = _clock();
    final retired = await _repository.retireStale(
      cutoff: AgingPolicy.cutoffFrom(now),
      at: now,
      reason: AgingPolicy.reason,
    );
    for (final id in retired) {
      await _scheduler.cancel(id);
    }
    return retired.length;
  }
}
