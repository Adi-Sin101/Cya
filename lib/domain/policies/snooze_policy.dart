import '../entities/intention.dart';

/// How prominently a due promise is surfaced (PRD §5.6 escalation).
///
/// A promise the user keeps pushing away rises in prominence rather than
/// quietly rotting in a list — the central defence against Cya! becoming a
/// second backlog (§12).
enum EscalationTier {
  /// Silent notification. First time a promise comes due.
  quiet('quiet'),

  /// Heads-up notification with actions. The user has pushed this back before.
  banner('banner'),

  /// Rolled into the review digest instead of interrupting again.
  digest('digest');

  const EscalationTier(this.wire);

  final String wire;
}

/// The snooze limit and escalation ladder. Pure domain policy: it decides,
/// the data layer records, the notification layer renders (PRD §5.6).
abstract final class SnoozePolicy {
  const SnoozePolicy._();

  /// After this many snoozes, Cya! stops offering "later" and asks the user to
  /// resolve, reschedule deliberately, or let the promise go.
  static const int maxSnoozes = 3;

  /// Default push-back when the user taps Snooze without choosing a time.
  static const Duration defaultSnooze = Duration(hours: 3);

  static bool canSnooze(Intention intention) =>
      intention.snoozeCount < maxSnoozes;

  /// Whether the UI should ask the user to close the loop instead of offering
  /// another snooze.
  static bool requiresResolutionPrompt(Intention intention) =>
      intention.snoozeCount >= maxSnoozes;

  /// How loudly this promise should come back, given how often it has been
  /// pushed away already.
  static EscalationTier tierFor(Intention intention) {
    if (intention.snoozeCount == 0) return EscalationTier.quiet;
    if (intention.snoozeCount < maxSnoozes) return EscalationTier.banner;
    return EscalationTier.digest;
  }
}
