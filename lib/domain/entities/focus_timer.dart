import 'dart:convert';

/// A user-chosen clock, never evidence that work or a routine was completed.
class FocusTimerSnapshot {
  const FocusTimerSnapshot({
    required this.sessionId,
    required this.priority,
    required this.durationSeconds,
    required this.remainingSeconds,
    this.deadline,
    this.occurrenceId,
  });
  final String sessionId, priority;
  final int durationSeconds, remainingSeconds;
  final DateTime? deadline;
  final String? occurrenceId;
  bool get running => deadline != null;
  int remainingAt(DateTime now) => deadline == null
      ? remainingSeconds
      : ((deadline!.millisecondsSinceEpoch -
                    now.millisecondsSinceEpoch +
                    999) ~/
                1000)
            .clamp(0, durationSeconds);
  String encode() => jsonEncode({
    'sessionId': sessionId,
    'priority': priority,
    'durationSeconds': durationSeconds,
    'remainingSeconds': remainingSeconds,
    'deadline': deadline?.millisecondsSinceEpoch,
    'occurrenceId': occurrenceId,
  });
  static FocusTimerSnapshot decode(String value) {
    final row = jsonDecode(value) as Map<String, dynamic>;
    final result = FocusTimerSnapshot(
      sessionId: row['sessionId'] as String,
      priority: row['priority'] as String,
      durationSeconds: row['durationSeconds'] as int,
      remainingSeconds: row['remainingSeconds'] as int,
      deadline: row['deadline'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row['deadline'] as int),
      occurrenceId: row['occurrenceId'] as String?,
    );
    if (result.sessionId.isEmpty ||
        result.priority.trim().isEmpty ||
        result.durationSeconds < 60 ||
        result.durationSeconds > 10800 ||
        result.remainingSeconds < 0 ||
        result.remainingSeconds > result.durationSeconds) {
      throw const FormatException('Invalid focus clock.');
    }
    return result;
  }
}
