/// Gamification level/XP snapshot shown on Home (PRD §6.6).
///
/// A projection over the event log in the target design; hardcoded for now.
class UserLevel {
  const UserLevel({
    required this.level,
    required this.title,
    required this.xp,
    required this.xpTarget,
  });

  final int level;

  /// Flavor title, e.g. "Future Builder".
  final String title;

  final int xp;
  final int xpTarget;

  /// Progress toward the next level, clamped to `0..1`.
  double get progress =>
      xpTarget <= 0 ? 0 : (xp / xpTarget).clamp(0, 1).toDouble();
}
