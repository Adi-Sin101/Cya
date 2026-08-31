import '../../domain/entities/intention.dart';
import '../../domain/enums/reminder_preset.dart';
import '../dao/intention_dao.dart';
import '../dao/preference_dao.dart';

/// Development-only seed of the promises shown in the approved Home mockup
/// (PRD §8.2), so the designed screen can be reviewed with realistic content.
///
/// Never runs in release builds — a real first launch starts empty and shows
/// the designed empty state. Guarded by a preference key so it happens once
/// even in debug, and skipped entirely if the store already has anything.
class DemoSeed {
  const DemoSeed(this._intentions, this._preferences);

  final IntentionDao _intentions;
  final PreferenceDao _preferences;

  Future<void> ensureSeeded(DateTime now) async {
    if (await _preferences.read(PreferenceDao.keySeeded) == 'true') return;
    if (await _intentions.countAll() > 0) {
      await _preferences.write(PreferenceDao.keySeeded, 'true');
      return;
    }

    final tonight = ReminderPreset.tonight.resolve(now);
    final tomorrow = ReminderPreset.tomorrow.resolve(now);
    final weekend = ReminderPreset.weekend.resolve(now);

    final samples = <NewIntention>[
      NewIntention(
        sourceApp: 'Messenger',
        rawContent: 'Reply to Sarah',
        snippet: '"are we still on for saturday?"',
        capturedAt: now.subtract(const Duration(hours: 3)),
        reminderAt: tonight,
      ),
      NewIntention(
        sourceApp: 'Chrome',
        rawContent: 'Read AI Paper',
        snippet: 'arxiv.org — attention is all you need',
        deepLink: 'https://arxiv.org/abs/1706.03762',
        capturedAt: now.subtract(const Duration(hours: 2)),
        reminderAt: tonight.add(const Duration(hours: 1)),
      ),
      NewIntention(
        sourceApp: 'GitHub',
        rawContent: 'Review PR #128',
        snippet: 'cya/feat: drift data foundation',
        capturedAt: now.subtract(const Duration(hours: 1)),
        reminderAt: tomorrow,
      ),
      NewIntention(
        sourceApp: 'Amazon',
        rawContent: 'Buy HDMI Cable',
        snippet: '2m, 4K120 — the one that fits the monitor',
        capturedAt: now.subtract(const Duration(minutes: 30)),
        reminderAt: weekend,
      ),
    ];

    for (final sample in samples) {
      await _intentions.capture(sample);
    }
    // One resolved promise so the Today ring and the garden are not empty.
    await _intentions.resolve(1, at: now.subtract(const Duration(minutes: 10)));
    await _preferences.write(PreferenceDao.keySeeded, 'true');
  }
}
