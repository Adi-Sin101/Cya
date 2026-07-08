/// The zero-tap reminder presets offered on capture (PRD §6.2).
///
/// Pure domain: no Flutter imports. Presentation maps these to icons/colors.
enum ReminderPreset { tonight, tomorrow, weekend }

extension ReminderPresetLabel on ReminderPreset {
  String get label => switch (this) {
    ReminderPreset.tonight => 'Tonight',
    ReminderPreset.tomorrow => 'Tomorrow',
    ReminderPreset.weekend => 'Weekend',
  };
}
