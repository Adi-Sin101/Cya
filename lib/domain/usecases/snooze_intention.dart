import '../../core/result.dart';
import '../../core/utils/clock.dart';
import '../policies/snooze_policy.dart';
import '../repositories/intention_repository.dart';
import '../services/reminder_scheduler.dart';

/// Push a promise back — but only as often as the product allows.
///
/// The snooze limit is enforced here, in the domain layer (PRD §5.6), so every
/// surface that can snooze (list, detail, notification action) gets the same
/// answer. Refusing a fourth snooze is a feature, not an error.
class SnoozeIntention {
  const SnoozeIntention(this._repository, this._clock, this._scheduler);

  final IntentionRepository _repository;
  final Clock _clock;
  final ReminderScheduler _scheduler;

  Future<Result<DateTime>> call(int id, {Duration? by, DateTime? until}) async {
    try {
      final intention = await _repository.findById(id);
      if (intention == null) return Result.failure(NotFoundError(id));

      if (!SnoozePolicy.canSnooze(intention)) {
        return Result.failure(
          SnoozeLimitError(intention.snoozeCount, SnoozePolicy.maxSnoozes),
        );
      }

      final now = _clock();
      final target = until ?? now.add(by ?? SnoozePolicy.defaultSnooze);
      await _repository.snooze(id, until: target, at: now);
      await _scheduler.schedule(id, target);
      return Result.success(target);
    } on Object catch (error, stackTrace) {
      return Result.failure(StorageError(error, stackTrace));
    }
  }
}
