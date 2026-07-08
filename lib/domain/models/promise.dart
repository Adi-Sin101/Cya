import '../enums/reminder_preset.dart';

/// A captured intention, surfaced to users as a "promise" (PRD §1.4, §7.1).
///
/// This is a lightweight presentation-facing model for the first iteration;
/// it will be superseded by the Drift-backed entity + event log later.
class Promise {
  const Promise({
    required this.id,
    required this.title,
    required this.sourceApp,
    required this.timeLabel,
    required this.preset,
    this.isCompleted = false,
  });

  final String id;

  /// User-facing title, e.g. "Reply to Sarah".
  final String title;

  /// Originating app, e.g. "Messenger".
  final String sourceApp;

  /// Human-readable capture/reminder time, e.g. "6:30 PM".
  final String timeLabel;

  final ReminderPreset preset;
  final bool isCompleted;

  Promise copyWith({bool? isCompleted}) {
    return Promise(
      id: id,
      title: title,
      sourceApp: sourceApp,
      timeLabel: timeLabel,
      preset: preset,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
