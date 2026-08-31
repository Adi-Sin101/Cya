/// The zero-tap reminder presets offered on capture (PRD §6.2).
///
/// Pure domain: no Flutter imports. Presentation maps these to icons/colors.
///
/// [resolve] is the single definition of what each preset *means* in wall-clock
/// terms. The native capture path (PRD §5.4) schedules the zero-tap default
/// with the same rule, so a promise captured natively and one captured in the
/// app land on the same instant. Changing a rule here changes the native
/// contract — see `docs/native_db_contract.md`.
enum ReminderPreset {
  tonight('Tonight'),
  tomorrow('Tomorrow'),
  weekend('Weekend');

  const ReminderPreset(this.label);

  /// User-facing chip text (PRD §8.2).
  final String label;

  /// The zero-tap default used by every capture surface when the user does not
  /// choose (PRD §6.1).
  static const ReminderPreset defaultPreset = ReminderPreset.tonight;

  /// Concrete reminder instant for this preset, relative to [now].
  ///
  /// - Tonight: today at 20:00; if it is already 20:00 or later, `now + 2h`
  ///   (a "tonight" reminder must still be tonight, and must be in the future).
  /// - Tomorrow: tomorrow at 09:00.
  /// - Weekend: the next Saturday at 10:00 (today, if today is Saturday and it
  ///   is before 10:00).
  DateTime resolve(DateTime now) {
    switch (this) {
      case ReminderPreset.tonight:
        final tonight = DateTime(now.year, now.month, now.day, 20);
        return now.isBefore(tonight)
            ? tonight
            : now.add(const Duration(hours: 2));
      case ReminderPreset.tomorrow:
        // The DateTime constructor normalizes day overflow, so this stays
        // correct across month ends and DST shifts (unlike adding a Duration).
        return DateTime(now.year, now.month, now.day + 1, 9);
      case ReminderPreset.weekend:
        final todayAtTen = DateTime(now.year, now.month, now.day, 10);
        final daysUntilSaturday = (DateTime.saturday - now.weekday) % 7;
        if (daysUntilSaturday == 0 && now.isBefore(todayAtTen)) {
          return todayAtTen;
        }
        final days = daysUntilSaturday == 0 ? 7 : daysUntilSaturday;
        return DateTime(now.year, now.month, now.day + days, 10);
    }
  }
}
