import '../../domain/enums/reminder_preset.dart';
import '../../domain/models/garden_summary.dart';
import '../../domain/models/home_summary.dart';
import '../../domain/models/promise.dart';
import '../../domain/models/user_level.dart';
import '../../domain/models/week_stats.dart';

/// The single source of hardcoded Home content for the first iteration.
///
/// This stands in for the reactive Drift-backed repository that arrives in a
/// later phase; the screen and providers are written against it so swapping in
/// the real data source is a localized change.
class MockHomeRepository {
  const MockHomeRepository();

  HomeSummary loadHomeSummary() {
    return const HomeSummary(
      userName: 'Arif',
      level: UserLevel(
        level: 12,
        title: 'Future Builder',
        xp: 2450,
        xpTarget: 3000,
      ),
      promises: <Promise>[
        Promise(
          id: 'p1',
          title: 'Reply to Sarah',
          sourceApp: 'Messenger',
          timeLabel: '6:30 PM',
          preset: ReminderPreset.tonight,
          isCompleted: true,
        ),
        Promise(
          id: 'p2',
          title: 'Read AI Paper',
          sourceApp: 'Chrome',
          timeLabel: '9:00 PM',
          preset: ReminderPreset.tonight,
        ),
        Promise(
          id: 'p3',
          title: 'Review PR #128',
          sourceApp: 'GitHub',
          timeLabel: 'Tomorrow',
          preset: ReminderPreset.tomorrow,
        ),
        Promise(
          id: 'p4',
          title: 'Buy HDMI Cable',
          sourceApp: 'Amazon',
          timeLabel: 'Sat',
          preset: ReminderPreset.weekend,
        ),
      ],
      week: WeekStats(
        captured: 12,
        completed: 8,
        trend: <double>[0.3, 0.45, 0.4, 0.6, 0.55, 0.75, 0.9],
      ),
      garden: GardenSummary(newGrowthsThisWeek: 4),
    );
  }
}
