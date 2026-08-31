/// Spacing, radius and hit-target tokens (PRD §8.1 "generous spacing", §8.4).
///
/// A 4dp-based scale with the small end deliberately thinned out: the reason
/// screens read as cluttered is usually that everything sits 8–12dp apart, so
/// nothing groups. Related things get [xs]/[sm]; unrelated things get [xl] or
/// more, and the eye does the grouping for free.
abstract final class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;

  /// Between sections that belong to the same idea.
  static const double xxl = 28;

  /// Between sections that do not.
  static const double section = 40;

  /// Horizontal page margin. Every screen uses this — a shared left edge is
  /// most of what makes a set of screens feel like one app.
  static const double page = 20;

  /// Bottom padding for scrollables, clearing the docked FAB that overhangs
  /// the nav bar. The bar itself is not overlapped (see `HomeShell`).
  static const double navClearance = 56;
}

/// Corner radii (PRD §8.1 — rounded, soft surfaces).
abstract final class AppRadius {
  const AppRadius._();

  /// Chips, small pills, inline tags.
  static const double sm = 12;

  /// Inner elements, inputs, tiles nested inside a card.
  static const double md = 16;

  /// Cards and list rows — the app's default.
  static const double lg = 20;

  /// Hero surfaces and sheets.
  static const double xl = 26;

  /// Full-bleed feature panels.
  static const double xxl = 32;
}

/// Minimum interactive sizes (PRD §8.4).
abstract final class AppTouch {
  const AppTouch._();

  /// The floor for anything tappable.
  static const double minTarget = 48;

  /// Primary buttons — sized to the new type scale, not to Material's default.
  static const double buttonHeight = 56;
}
