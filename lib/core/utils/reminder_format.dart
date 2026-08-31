/// How a reminder time reads to the user (PRD §8.2 preset chips).
enum ReminderKind { none, overdue, today, tonight, tomorrow, weekend, later }

/// The two strings a promise row shows for its reminder: the chip
/// ("Tonight", "Overdue") and the inline time ("8:00 PM", "Sat").
class ReminderDisplay {
  const ReminderDisplay({
    required this.kind,
    required this.chipLabel,
    required this.timeLabel,
  });

  final ReminderKind kind;
  final String chipLabel;
  final String timeLabel;
}

/// Derives the display from the stored `reminderAt` rather than storing a
/// preset alongside it — one source of truth, and it stays correct as time
/// passes (a "Tomorrow" promise reads "Today" tomorrow).
ReminderDisplay describeReminder(DateTime? reminderAt, DateTime now) {
  if (reminderAt == null) {
    return const ReminderDisplay(
      kind: ReminderKind.none,
      chipLabel: 'Someday',
      timeLabel: 'no reminder',
    );
  }

  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(reminderAt.year, reminderAt.month, reminderAt.day);
  final dayDelta = target.difference(today).inDays;

  if (reminderAt.isBefore(now)) {
    return ReminderDisplay(
      kind: ReminderKind.overdue,
      chipLabel: 'Overdue',
      timeLabel: dayDelta == 0
          ? formatTimeOfDay(reminderAt)
          : formatDay(reminderAt),
    );
  }

  if (dayDelta == 0) {
    final isEvening = reminderAt.hour >= 17;
    return ReminderDisplay(
      kind: isEvening ? ReminderKind.tonight : ReminderKind.today,
      chipLabel: isEvening ? 'Tonight' : 'Today',
      timeLabel: formatTimeOfDay(reminderAt),
    );
  }

  if (dayDelta == 1) {
    return ReminderDisplay(
      kind: ReminderKind.tomorrow,
      chipLabel: 'Tomorrow',
      timeLabel: formatTimeOfDay(reminderAt),
    );
  }

  final isWeekendDay =
      reminderAt.weekday == DateTime.saturday ||
      reminderAt.weekday == DateTime.sunday;
  if (dayDelta < 7 && isWeekendDay) {
    return ReminderDisplay(
      kind: ReminderKind.weekend,
      chipLabel: 'Weekend',
      timeLabel: _weekdayNames[reminderAt.weekday - 1],
    );
  }

  return ReminderDisplay(
    kind: ReminderKind.later,
    chipLabel: dayDelta < 7 ? _weekdayNames[reminderAt.weekday - 1] : 'Later',
    timeLabel: formatDay(reminderAt),
  );
}

/// `18:05` → `6:05 PM`. English-only in V1 (PRD scope); swap for `intl` when
/// localization lands.
String formatTimeOfDay(DateTime time) {
  final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.hour < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $suffix';
}

/// `Mar 3` — used once a reminder is far enough out that a weekday is unclear.
String formatDay(DateTime day) => '${_monthNames[day.month - 1]} ${day.day}';

String formatWeekday(DateTime day) => _weekdayNames[day.weekday - 1];

const List<String> _weekdayNames = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

const List<String> _monthNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
