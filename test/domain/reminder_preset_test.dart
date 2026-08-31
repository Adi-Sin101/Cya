import 'package:cya/domain/enums/reminder_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReminderPreset.resolve', () {
    test('tonight is 20:00 today when the evening has not started', () {
      final now = DateTime(2026, 3, 3, 14, 12);
      expect(ReminderPreset.tonight.resolve(now), DateTime(2026, 3, 3, 20));
    });

    test('tonight stays in the future once 20:00 has passed', () {
      final now = DateTime(2026, 3, 3, 21, 30);
      expect(ReminderPreset.tonight.resolve(now), DateTime(2026, 3, 3, 23, 30));
    });

    test('tomorrow is 09:00 the next day, across a month boundary', () {
      final now = DateTime(2026, 3, 31, 22);
      expect(ReminderPreset.tomorrow.resolve(now), DateTime(2026, 4, 1, 9));
    });

    test('weekend is the coming Saturday at 10:00', () {
      // 2026-03-03 is a Tuesday.
      final now = DateTime(2026, 3, 3, 8);
      expect(now.weekday, DateTime.tuesday);
      expect(ReminderPreset.weekend.resolve(now), DateTime(2026, 3, 7, 10));
    });

    test('weekend is today when it is Saturday morning', () {
      final now = DateTime(2026, 3, 7, 7);
      expect(now.weekday, DateTime.saturday);
      expect(ReminderPreset.weekend.resolve(now), DateTime(2026, 3, 7, 10));
    });

    test('weekend rolls to next Saturday once Saturday 10:00 has passed', () {
      final now = DateTime(2026, 3, 7, 11);
      expect(ReminderPreset.weekend.resolve(now), DateTime(2026, 3, 14, 10));
    });

    test('every preset resolves to a future instant', () {
      final now = DateTime(2026, 3, 7, 23, 59);
      for (final preset in ReminderPreset.values) {
        expect(
          preset.resolve(now).isAfter(now),
          isTrue,
          reason: '${preset.name} must be in the future',
        );
      }
    });
  });
}
