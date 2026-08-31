import '../../core/result.dart';
import '../../core/utils/clock.dart';
import '../repositories/intention_repository.dart';
import '../services/reminder_scheduler.dart';

/// The remaining single-promise commands: reschedule, recategorize, edit,
/// archive, delete (PRD §6.3, §3.5).
///
/// Grouped in one use-case because they share one shape — validate, write,
/// log — and splitting them into five classes would be ceremony, not design.
class ManageIntention {
  const ManageIntention(this._repository, this._clock, this._scheduler);

  final IntentionRepository _repository;
  final Clock _clock;
  final ReminderScheduler _scheduler;

  Future<Result<void>> reschedule(int id, DateTime? reminderAt) =>
      _guard(() async {
        await _repository.updateReminder(
          id,
          reminderAt: reminderAt,
          at: _clock(),
        );
        if (reminderAt == null) {
          await _scheduler.cancel(id);
        } else {
          await _scheduler.schedule(id, reminderAt);
        }
      });

  Future<Result<void>> categorize(int id, String? category) => _guard(
    () => _repository.updateCategory(id, category: category, at: _clock()),
  );

  Future<Result<void>> edit(int id, String rawContent) {
    final content = rawContent.trim();
    if (content.isEmpty) {
      return Future.value(
        const Result.failure(ValidationError('A promise needs some content.')),
      );
    }
    return _guard(
      () => _repository.updateContent(id, rawContent: content, at: _clock()),
    );
  }

  Future<Result<void>> archive(int id) => _guard(() async {
    await _repository.archive(id, at: _clock());
    await _scheduler.cancel(id);
  });

  /// Permanent, at the user's explicit request (PRD §3.5).
  Future<Result<void>> delete(int id) => _guard(() async {
    await _repository.deleteIntention(id);
    await _scheduler.cancel(id);
  });

  Future<Result<void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Result.success(null);
    } on Object catch (error, stackTrace) {
      return Result.failure(StorageError(error, stackTrace));
    }
  }
}
