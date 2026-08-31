import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../domain/entities/intention.dart';

/// Whether reminders are actually arriving (PRD §9.2 reliability, §12 the OEM
/// battery-optimization risk).
///
/// A forgotten reminder is fatal for a memory product, so the app does not
/// assume the OS kept its promise — it checks. Because every fired reminder
/// writes a `resurfaced` event, a due promise with no such event is evidence
/// that the alarm was dropped.
class ReminderHealth {
  const ReminderHealth({required this.missed, required this.exactAllowed});

  final List<Intention> missed;

  /// Whether the OS still lets Cya! schedule exact alarms.
  final bool exactAllowed;

  bool get isHealthy => missed.isEmpty && exactAllowed;
}

final reminderHealthProvider = FutureProvider.autoDispose<ReminderHealth>((
  ref,
) async {
  final repository = ref.watch(intentionRepositoryProvider);
  final port = ref.watch(reminderPortProvider);
  final missed = await repository.missedReminders(ref.watch(clockProvider)());
  final exactAllowed = await port.canScheduleExact();
  return ReminderHealth(missed: missed, exactAllowed: exactAllowed);
});
