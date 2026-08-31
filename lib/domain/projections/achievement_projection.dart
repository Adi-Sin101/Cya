/// The counts every achievement is decided from (PRD §6.6).
///
/// Gathered by narrow aggregate queries, not by streaming the event log.
class AchievementStats {
  const AchievementStats({
    this.captured = 0,
    this.resolved = 0,
    this.linksResolved = 0,
    this.conversationsResolved = 0,
    this.streakDays = 0,
  });

  final int captured;
  final int resolved;

  /// Resolved promises that carried a link — the "read it later" ones.
  final int linksResolved;

  /// Resolved promises captured from a messaging app.
  final int conversationsResolved;

  final int streakDays;
}

/// A badge, and how close the user is to it.
class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.progress,
    required this.target,
  });

  final String id;
  final String name;
  final String description;
  final String emoji;

  /// How far along, never above [target].
  final int progress;
  final int target;

  bool get isUnlocked => progress >= target;

  double get fraction =>
      target <= 0 ? 1 : (progress / target).clamp(0, 1).toDouble();
}

/// Achievements are **predicates over counts**, evaluated on demand (PRD §6.6,
/// ADR-002). Nothing is stored: no `unlocked_at` column that can disagree with
/// the event log, and no way to end up with a badge the events don't justify.
abstract final class AchievementProjection {
  const AchievementProjection._();

  static List<Achievement> evaluate(AchievementStats stats) => <Achievement>[
    Achievement(
      id: 'first_step',
      name: 'First Step',
      description: 'Capture your first promise.',
      emoji: '🌱',
      progress: stats.captured.clamp(0, 1),
      target: 1,
    ),
    Achievement(
      id: 'never_lost',
      name: 'Never Lost',
      description: 'Keep 100 promises you would have forgotten.',
      emoji: '🧭',
      progress: stats.resolved,
      target: 100,
    ),
    Achievement(
      id: 'reader',
      name: 'Reader',
      description: 'Actually read 50 things you saved for later.',
      emoji: '📚',
      progress: stats.linksResolved,
      target: 50,
    ),
    Achievement(
      id: 'communicator',
      name: 'Communicator',
      description: 'Reply to 100 conversations you meant to get back to.',
      emoji: '💬',
      progress: stats.conversationsResolved,
      target: 100,
    ),
    Achievement(
      id: 'future_you',
      name: 'Future You',
      description: 'Keep 500 promises. Future you is doing well.',
      emoji: '🔮',
      progress: stats.resolved,
      target: 500,
    ),
    Achievement(
      id: 'legend',
      name: 'Legend',
      description: 'Keep 1,000 promises.',
      emoji: '🏆',
      progress: stats.resolved,
      target: 1000,
    ),
  ];

  static List<Achievement> unlocked(AchievementStats stats) =>
      evaluate(stats).where((a) => a.isUnlocked).toList(growable: false);

  /// Which badges a change earned — the input to a celebration. Comparing two
  /// evaluations is enough; there is no unlock event to miss.
  static List<Achievement> newlyUnlocked(
    AchievementStats before,
    AchievementStats after,
  ) {
    final had = unlocked(before).map((a) => a.id).toSet();
    return unlocked(after).where((a) => !had.contains(a.id)).toList();
  }
}
