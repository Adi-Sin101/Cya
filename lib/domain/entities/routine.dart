import 'dart:convert';

String localDayKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
DateTime parseLocalDay(String key) {
  final date = DateTime.tryParse(key);
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key) ||
      date == null ||
      localDayKey(date) != key) {
    throw const FormatException('Choose a valid day.');
  }
  return DateTime(date.year, date.month, date.day);
}

List<String> routineSteps(String json) {
  final values = jsonDecode(json);
  if (values is! List ||
      values.length > 50 ||
      values.any((s) => s is! String || s.trim().isEmpty || s.length > 500)) {
    throw const FormatException(
      'Use up to50 nonempty steps, each within500 characters.',
    );
  }
  return values.cast<String>();
}

void validateRoutine({
  required String title,
  required List<String> steps,
  int? weekdays,
  int? start,
  int? end,
  String? fallback,
}) {
  if (title.trim().isEmpty ||
      title.length > 160 ||
      (weekdays != null && (weekdays < 1 || weekdays > 127)) ||
      (start != null && (start < 0 || start > 1439)) ||
      (end != null && (start == null || end < start || end > 1439)) ||
      (fallback?.length ?? 0) > 1000) {
    throw const FormatException(
      'Choose a title and valid weekdays / same-day preferred window.',
    );
  }
  routineSteps(jsonEncode(steps));
}

class Routine {
  const Routine({
    required this.id,
    required this.revisionId,
    required this.revision,
    required this.title,
    required this.steps,
    required this.position,
    required this.paused,
    this.deleted = false,
    this.weekdays,
    this.start,
    this.end,
    this.fallback,
  });
  final String id, revisionId, title;
  final int revision, position;
  final bool paused;
  final bool deleted;
  final List<String> steps;
  final int? weekdays, start, end;
  final String? fallback;
  bool eligible(DateTime day) => !deleted && !paused &&
      (weekdays == null || (weekdays! & (1 << (day.weekday - 1))) != 0);
}

class RoutineOccurrence {
  const RoutineOccurrence({
    required this.id,
    required this.routineId,
    required this.revisionId,
    required this.title,
    required this.version,
    required this.state,
    required this.selectedDay,
    required this.targetDay,
    required this.steps,
    required this.position,
    this.start,
    this.end,
    this.fallback,
  });
  final String id, routineId, revisionId, title, state, selectedDay, targetDay;
  final int version, position;
  final List<String> steps;
  final int? start, end;
  final String? fallback;
  bool get open => state == 'planned' || state == 'deferred';
}

class LocalReviewFacts {
  const LocalReviewFacts({
    required this.routineStates,
    required this.promisesCompleted,
    required this.promisesDeferred,
    required this.routinesSelected,
    required this.adjustmentEvidence,
  });
  final Map<String, int> routineStates;
  final int promisesCompleted, promisesDeferred, routinesSelected;

  /// Descriptive local evidence only. Never an automatic plan mutation.
  final List<String> adjustmentEvidence;
}
