import 'package:flutter/services.dart';

/// The OEM families that stop background apps by default, and therefore stop
/// reminders (PRD §12; iteration 9, defect D-4).
///
/// Named rather than lumped together because the *fix* differs: on Xiaomi it is
/// an Autostart list buried in the Security app, on Samsung it is "Never
/// sleeping apps" inside battery care. Onboarding has to send the user to the
/// right one — it cannot say "somewhere in settings".
enum DeviceOem {
  xiaomi,
  samsung,
  oppo,
  vivo,
  huawei,
  oneplus,

  /// Stock-ish Android, or an OEM without a known autostart gate. The battery
  /// exemption and exact alarms still apply; autostart does not.
  other;

  bool get hasAutostartGate => this != DeviceOem.other;
}

/// A snapshot of whether this device will actually let a reminder fire.
///
/// Read, never cached: every one of these can change while the user is standing
/// in the settings screen we just sent them to, and the checklist has to
/// re-tick when they come back.
class DeviceReliability {
  const DeviceReliability({
    required this.oem,
    required this.manufacturer,
    required this.osLabel,
    required this.batteryUnrestricted,
    required this.exactAlarms,
    required this.notifications,
  });

  /// What a device looks like before the native side has answered: assume the
  /// good case, so the checklist never flashes a problem that isn't there.
  static const DeviceReliability unknown = DeviceReliability(
    oem: DeviceOem.other,
    manufacturer: '',
    osLabel: '',
    batteryUnrestricted: true,
    exactAlarms: true,
    notifications: true,
  );

  final DeviceOem oem;

  /// For display — "Xiaomi", "Samsung".
  final String manufacturer;

  /// The skin, when we can name it — "HyperOS", "One UI". Empty otherwise.
  final String osLabel;

  /// Whether Cya! is exempt from battery optimisation.
  final bool batteryUnrestricted;

  /// Whether exact alarms are permitted (Android 12+).
  final bool exactAlarms;

  /// Whether notifications may be posted (Android 13+).
  final bool notifications;

  /// Autostart cannot be *read* — no OEM exposes an API for it — so it is
  /// something the user confirms rather than something we detect.
  bool get needsAutostartStep => oem.hasAutostartGate;

  /// The device label for the onboarding chip, e.g. "Xiaomi · HyperOS".
  String get label {
    if (manufacturer.isEmpty) return 'This device';
    return osLabel.isEmpty ? manufacturer : '$manufacturer · $osLabel';
  }
}

/// Reads and opens the OEM settings that decide whether reminders arrive.
///
/// Shares the reminder channel because that is exactly the question it answers:
/// the channel already carries `canScheduleExact` and the notification
/// permission, and "will my alarm fire on this phone" is one subject, not three.
class DeviceReliabilityPort {
  const DeviceReliabilityPort([this._channel = _defaultChannel]);

  static const MethodChannel _defaultChannel = MethodChannel('cya/reminders');

  final MethodChannel _channel;

  Future<DeviceReliability> read() async {
    final raw = await _invoke<Map<Object?, Object?>>('deviceReliability');
    if (raw == null) return DeviceReliability.unknown;
    return DeviceReliability(
      oem: _oemFrom(raw['oem'] as String?),
      manufacturer: raw['manufacturer'] as String? ?? '',
      osLabel: raw['osLabel'] as String? ?? '',
      batteryUnrestricted: raw['batteryUnrestricted'] as bool? ?? true,
      exactAlarms: raw['exactAlarms'] as bool? ?? true,
      notifications: raw['notifications'] as bool? ?? true,
    );
  }

  /// Opens the OEM's autostart list. Returns whether anything opened — several
  /// OEMs rename or remove the activity between versions, and the UI must then
  /// tell the user where to look rather than appear to do nothing.
  Future<bool> openAutostartSettings() async =>
      await _invoke<bool>('openAutostartSettings') ?? false;

  /// Asks for the battery-optimisation exemption. Reminders are this app's core
  /// function, which is what makes the request legitimate (PRD §12).
  Future<bool> openBatterySettings() async =>
      await _invoke<bool>('openBatterySettings') ?? false;

  Future<void> openExactAlarmSettings() =>
      _invoke<void>('openExactAlarmSettings');

  /// This app's system settings page — the universal fallback when an
  /// OEM-specific screen could not be resolved.
  Future<bool> openAppSettings() async =>
      await _invoke<bool>('openAppSettings') ?? false;

  static DeviceOem _oemFrom(String? value) => switch (value) {
    'xiaomi' => DeviceOem.xiaomi,
    'samsung' => DeviceOem.samsung,
    'oppo' => DeviceOem.oppo,
    'vivo' => DeviceOem.vivo,
    'huawei' => DeviceOem.huawei,
    'oneplus' => DeviceOem.oneplus,
    _ => DeviceOem.other,
  };

  Future<T?> _invoke<T>(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
