/// Weekly capture/completion stats shown on Home (PRD §6.6, §11).
class WeekStats {
  const WeekStats({
    required this.captured,
    required this.completed,
    required this.trend,
  });

  final int captured;
  final int completed;

  /// Normalized (0..1) points for the encouraging trend line.
  final List<double> trend;

  /// Share of captured promises that were completed, `0..1`.
  double get successRate => captured <= 0 ? 0 : completed / captured;
}
