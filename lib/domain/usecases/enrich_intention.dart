import '../../core/utils/clock.dart';
import '../entities/intention.dart';
import '../repositories/intention_repository.dart';
import '../services/enrichment.dart';
import '../services/reminder_scheduler.dart';

/// Runs enrichment over promises that have not been enriched yet (PRD §5.5).
///
/// **This is not on the capture path** (PRD §3.2). It is triggered after the
/// UI is up, and it is allowed to take as long as it likes.
///
/// It is deliberately conservative about writing:
///
/// - a **category** is only set when the promise has none, so it can never
///   overwrite a choice the user made by hand;
/// - an **extracted deadline** is recorded as a suggestion, and the actual
///   reminder is only moved when the user has not touched it — a promise that
///   has been snoozed has a reminder time the user chose, and enrichment does
///   not get to override that.
///
/// The category write goes through [IntentionRepository.updateCategory], which
/// logs its `edited` event in the same transaction — enrichment is a mutation
/// like any other and does not get to skip the event log (PRD §7.1).
class EnrichIntention {
  const EnrichIntention(
    this._repository,
    this._clock,
    this._scheduler, {
    Analyzer? analyzer,
  }) : _analyze = analyzer ?? EnrichmentService.analyze;

  final IntentionRepository _repository;
  final Clock _clock;
  final ReminderScheduler _scheduler;
  final Analyzer _analyze;

  /// Enriches [promises] and returns how many were changed.
  ///
  /// Takes the list rather than querying, so the caller decides the scope and
  /// this stays trivially testable.
  Future<int> run(List<Intention> promises) async {
    var changed = 0;
    for (final promise in promises) {
      if (await _enrichOne(promise)) changed++;
    }
    return changed;
  }

  Future<bool> _enrichOne(Intention promise) async {
    // Already enriched, or the user already filed it: nothing to do. Checking
    // both means a re-run over the whole table is cheap and idempotent.
    final needsCategory = promise.category == null;
    final needsDeadline = promise.extractedDeadline == null;
    if (!needsCategory && !needsDeadline) return false;

    final result = _analyze(promise.rawContent, promise.capturedAt);
    if (result.isEmpty) return false;

    final now = _clock();
    var wrote = false;

    if (needsCategory && result.category != null) {
      await _repository.updateCategory(
        promise.id,
        category: result.category,
        at: now,
      );
      wrote = true;
    }

    final extracted = result.deadline;
    if (needsDeadline && extracted != null) {
      final deadline = extracted;
      // Only move the reminder when it is still the untouched zero-tap
      // default and the extracted time is in the future. A user who snoozed
      // this, or picked a date, has said what they want.
      final untouched = promise.snoozeCount == 0;
      final worthMoving =
          untouched &&
          deadline.isAfter(now) &&
          promise.reminderAt != null &&
          deadline != promise.reminderAt;

      await _repository.recordExtractedDeadline(
        promise.id,
        deadline: deadline,
        reminderAt: worthMoving ? deadline : null,
        at: now,
      );
      // Moving the row without re-arming the alarm would leave the store and
      // AlarmManager disagreeing about when this promise comes back — and the
      // alarm is the half the user actually experiences (PRD §3.4).
      if (worthMoving) await _scheduler.schedule(promise.id, deadline);
      wrote = true;
    }

    return wrote;
  }
}

/// The analysis function, injectable so the use-case can be tested without
/// depending on the rule set.
typedef Analyzer = Enrichment Function(String content, DateTime capturedAt);
