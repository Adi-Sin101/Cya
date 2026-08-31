import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_motion.dart';

/// The only place in the app that touches [HapticFeedback].
///
/// Haptics are a vocabulary, not decoration: if every tap buzzes the same way,
/// the buzz stops meaning anything. The five entries below are the whole
/// vocabulary, and each one has exactly one meaning:
///
/// | call | meaning | where |
/// |---|---|---|
/// | [tap] | you touched a control | chips, nav, list rows |
/// | [selection] | the selection moved | filters, presets, pickers |
/// | [confirm] | something was committed | save, snooze, category set |
/// | [celebrate] | you kept a promise | resolution, level-up, unlock |
/// | [warn] | that did not work | validation, failed write |
///
/// Every call takes a [BuildContext] so it can be suppressed for users who
/// asked the platform to reduce motion (PRD §8.3/§8.4) — a device set to calm
/// down should not be buzzed at either. Feedback is fire-and-forget: a haptic
/// that fails is never worth an error path in front of the user.
abstract final class CyaHaptics {
  const CyaHaptics._();

  /// A control was touched. The lightest thing the device can do.
  static void tap(BuildContext context) =>
      _fire(context, HapticFeedback.selectionClick);

  /// The selection moved to a different value.
  static void selection(BuildContext context) =>
      _fire(context, HapticFeedback.selectionClick);

  /// Something was written down. Heavier than [tap] on purpose — this is the
  /// one the user should feel through a pocket.
  static void confirm(BuildContext context) =>
      _fire(context, HapticFeedback.lightImpact);

  /// A promise was kept. The only place a medium impact is allowed, so that
  /// keeping a promise is physically distinct from everything else.
  static void celebrate(BuildContext context) =>
      _fire(context, HapticFeedback.mediumImpact);

  /// Something refused to happen.
  static void warn(BuildContext context) =>
      _fire(context, HapticFeedback.heavyImpact);

  static void _fire(BuildContext context, Future<void> Function() feedback) {
    if (AppMotion.isReduced(context)) return;
    // Unawaited by design: the UI never blocks on the vibrator, and a platform
    // that has none (a tablet, a test harness) is not an error worth surfacing.
    feedback().ignore();
  }
}
