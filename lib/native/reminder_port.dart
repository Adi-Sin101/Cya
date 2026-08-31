import 'package:flutter/services.dart';

/// The bridge to the native reminder scheduler (PRD §5.6).
///
/// The app does **not** schedule reminders itself: it asks the same native
/// `AlarmManager` code the Share Sheet capture path uses, so a promise saved in
/// the app and one saved from a share behave identically — and a reminder can
/// still fire when the Flutter engine has never started.
///
/// Every call tolerates a missing native side (tests, desktop, iOS before its
/// scheduler lands): the promise is still saved, and the missing alarm is what
/// the reminder-health check surfaces rather than a crash.
class ReminderPort {
  const ReminderPort([this._channel = _defaultChannel]);

  static const MethodChannel _defaultChannel = MethodChannel('cya/reminders');

  final MethodChannel _channel;

  Future<void> schedule(int intentionId, DateTime at) => _invoke<void>(
    'schedule',
    <String, Object?>{'id': intentionId, 'atMillis': at.millisecondsSinceEpoch},
  );

  Future<void> cancel(int intentionId) =>
      _invoke<void>('cancel', <String, Object?>{'id': intentionId});

  /// Re-arms every pending reminder from the store — cheap insurance against an
  /// OEM that dropped alarms while the app was away (PRD §12).
  Future<int> rescheduleAll() async => await _invoke<int>('rescheduleAll') ?? 0;

  /// Whether exact alarms are permitted. When they are not, reminders still
  /// fire — just in an OS-chosen window — and the app says so rather than
  /// pretending nothing changed (PRD §12).
  Future<bool> canScheduleExact() async =>
      await _invoke<bool>('canScheduleExact') ?? true;

  Future<void> openExactAlarmSettings() =>
      _invoke<void>('openExactAlarmSettings');

  /// Asks for notification permission at the moment it makes sense — right
  /// after a capture, when "I'll bring this back tonight" is the obvious reason
  /// (PRD §3.5: permission is requested with its purpose visible, never up
  /// front). Returns whether Cya! may post notifications.
  Future<bool> ensureNotificationPermission() async =>
      await _invoke<bool>('ensureNotificationPermission') ?? true;

  /// The deep link that launched the app, if a reminder notification did
  /// (`cya://promise/<id>`). Consumed once.
  Future<String?> consumeInitialDeepLink() =>
      _invoke<String>('consumeInitialDeepLink');

  /// Deep links that arrive while the app is already running.
  void onDeepLink(void Function(String link) handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink' && call.arguments is String) {
        handler(call.arguments as String);
      }
      return null;
    });
  }

  Future<T?> _invoke<T>(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      // The native side refused (a revoked permission, most likely). Never let
      // that take the UI down — reminder health reports it instead.
      return null;
    }
  }
}
