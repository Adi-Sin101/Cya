import 'package:flutter/widgets.dart';

/// Motion tokens (PRD §8.3).
///
/// One place to tune how the whole app feels. The rule behind the numbers:
/// anything the user *caused* must acknowledge them inside [instant]–[quick]
/// (below the ~120ms where a response stops feeling attached to the tap);
/// anything that merely *arrives* may take [gentle] or longer.
///
/// Curves are chosen, not defaulted. [enter] overshoots slightly so things
/// arriving feel alive; [exit] does not, because a control springing on the way
/// out reads as a glitch.
abstract final class AppMotion {
  const AppMotion._();

  /// A state flip the user is watching for — a checkbox filling.
  static const Duration instant = Duration(milliseconds: 120);

  /// The default for micro-interactions: chips, taps, tints.
  static const Duration quick = Duration(milliseconds: 200);

  /// Content settling into place, cards expanding, sheets.
  static const Duration gentle = Duration(milliseconds: 320);

  /// Screen-level transitions and one-shot entrances.
  static const Duration slow = Duration(milliseconds: 480);

  /// Celebration. Long enough to register, short enough to never be in the way.
  static const Duration reward = Duration(milliseconds: 1100);

  /// Ambient loops — a garden breathing, a gradient drifting.
  static const Duration ambient = Duration(seconds: 7);

  /// Delay between successive items in a staggered entrance.
  static const Duration stagger = Duration(milliseconds: 55);

  /// Arriving content: decelerating with a whisper of overshoot.
  static const Curve enter = Curves.easeOutCubic;

  /// Emphasised arrival for things that should feel like they *grew*.
  static const Curve grow = Curves.easeOutBack;

  /// Leaving content: no overshoot.
  static const Curve exit = Curves.easeInCubic;

  /// Both directions — the safe default for [AnimatedContainer] and friends.
  static const Curve standard = Curves.easeInOutCubic;

  /// Loops that must not have a visible seam.
  static const Curve seamless = Curves.easeInOut;

  /// Whether the platform has asked us to calm down (PRD §8.3, §8.4).
  ///
  /// Every animated surface reads this and renders its *finished* state rather
  /// than simply playing faster — a reduced-motion user should see the whole
  /// UI, just still.
  static bool isReduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// [duration], or [Duration.zero] when motion is reduced.
  static Duration of(BuildContext context, Duration duration) =>
      isReduced(context) ? Duration.zero : duration;
}
