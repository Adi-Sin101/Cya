import 'garden_summary.dart';
import 'promise.dart';
import 'user_level.dart';
import 'week_stats.dart';

/// Aggregate of everything the Home screen renders (PRD §8.2).
class HomeSummary {
  const HomeSummary({
    required this.userName,
    required this.level,
    required this.promises,
    required this.week,
    required this.garden,
  });

  final String userName;
  final UserLevel level;
  final List<Promise> promises;
  final WeekStats week;
  final GardenSummary garden;

  int get todayTotal => promises.length;
  int get todayCompleted => promises.where((p) => p.isCompleted).length;

  HomeSummary copyWith({List<Promise>? promises}) {
    return HomeSummary(
      userName: userName,
      level: level,
      promises: promises ?? this.promises,
      week: week,
      garden: garden,
    );
  }
}
