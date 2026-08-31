import '../../core/result.dart';
import '../../core/utils/clock.dart';
import '../entities/intention.dart';
import '../enums/reminder_preset.dart';
import '../repositories/intention_repository.dart';
import '../services/reminder_scheduler.dart';

/// Save a new promise (PRD §3.2).
///
/// This is the *in-app* capture path. It does the same minimum the native
/// surfaces do — one insert plus a default reminder — and nothing more: no
/// network, no inference. Enrichment happens later, off this path.
class CaptureIntention {
  const CaptureIntention(this._repository, this._clock, this._scheduler);

  final IntentionRepository _repository;
  final Clock _clock;
  final ReminderScheduler _scheduler;

  /// Source label used when the user types straight into the app.
  static const String inAppSource = 'Cya!';

  Future<Result<int>> call({
    required String rawContent,
    String sourceApp = inAppSource,
    ReminderPreset? preset,
    DateTime? reminderAt,
    String? snippet,
    String? deepLink,
  }) async {
    final content = rawContent.trim();
    if (content.isEmpty) {
      return const Result.failure(
        ValidationError('Write or paste something to save.'),
      );
    }

    final now = _clock();
    // Zero-tap default: every surface can complete a capture with no extra
    // taps (PRD §6.1).
    final reminder =
        reminderAt ?? (preset ?? ReminderPreset.defaultPreset).resolve(now);

    try {
      final id = await _repository.capture(
        NewIntention(
          sourceApp: sourceApp,
          rawContent: content,
          snippet: snippet,
          deepLink: deepLink,
          capturedAt: now,
          reminderAt: reminder,
        ),
      );
      // Capture is not finished until the promise is scheduled to come back
      // — capture without resurfacing is just another inbox (PRD §3.4).
      await _scheduler.schedule(id, reminder);
      return Result.success(id);
    } on Object catch (error, stackTrace) {
      return Result.failure(StorageError(error, stackTrace));
    }
  }
}
