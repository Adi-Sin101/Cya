import '../../core/result.dart';
import '../../core/utils/clock.dart';
import '../enums/intention_status.dart';
import '../repositories/intention_repository.dart';

/// Close the loop on a promise (PRD §3.4) — and undo it.
///
/// Resolution must be as frictionless as capture, so this is a single call
/// reachable from the list, the detail screen and the notification itself.
class ResolveIntention {
  const ResolveIntention(this._repository, this._clock);

  final IntentionRepository _repository;
  final Clock _clock;

  Future<Result<void>> call(int id) async {
    try {
      await _repository.resolve(id, at: _clock());
      return const Result.success(null);
    } on Object catch (error, stackTrace) {
      return Result.failure(StorageError(error, stackTrace));
    }
  }

  /// Flip completion both ways — what the Home checkbox does.
  Future<Result<void>> toggle(int id) async {
    try {
      final intention = await _repository.findById(id);
      if (intention == null) return Result.failure(NotFoundError(id));
      final now = _clock();
      if (intention.status == IntentionStatus.resolved) {
        await _repository.reopen(id, at: now);
      } else {
        await _repository.resolve(id, at: now);
      }
      return const Result.success(null);
    } on Object catch (error, stackTrace) {
      return Result.failure(StorageError(error, stackTrace));
    }
  }
}
