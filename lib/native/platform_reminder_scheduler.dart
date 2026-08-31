import '../domain/services/reminder_scheduler.dart';
import 'reminder_port.dart';

/// Routes the domain's scheduling calls to the native `AlarmManager` — the same
/// scheduler the Share Sheet capture path uses, so both surfaces behave
/// identically (PRD §5.4, §5.6).
class PlatformReminderScheduler implements ReminderScheduler {
  const PlatformReminderScheduler([this._port = const ReminderPort()]);

  final ReminderPort _port;

  @override
  Future<void> schedule(int intentionId, DateTime at) =>
      _port.schedule(intentionId, at);

  @override
  Future<void> cancel(int intentionId) => _port.cancel(intentionId);
}
