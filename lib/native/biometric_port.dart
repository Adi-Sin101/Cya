import 'package:flutter/services.dart';

/// What the device can do about fingerprints.
enum BiometricAvailability {
  /// Hardware is present and at least one biometric is enrolled.
  ready,

  /// Hardware is present but nothing is enrolled — the user can fix this in
  /// system settings, so the UI offers rather than hides the option.
  notEnrolled,

  /// No usable hardware, or an OS too old for the prompt. The PIN is the only
  /// way in, which is exactly why the PIN is never optional alongside it.
  unavailable,
}

/// The fingerprint prompt (ADR-010).
///
/// Native Kotlin over the existing reminder channel rather than a plugin, for
/// the same reason notifications and alarms are (see PRD §13.3): this app
/// already owns a Kotlin surface, the framework `BiometricPrompt` needs no
/// dependency, and adding `local_auth` would have meant re-parenting the host
/// activity and its themes to AppCompat to satisfy a plugin's dialog.
///
/// Every call tolerates a missing native side — desktop, tests, iOS before its
/// native half exists — by reporting [BiometricAvailability.unavailable] and
/// falling back to the PIN. A biometric that cannot be offered is a smaller
/// problem than a crash between someone and their promises.
class BiometricPort {
  const BiometricPort([this._channel = _defaultChannel]);

  static const MethodChannel _defaultChannel = MethodChannel('cya/reminders');

  final MethodChannel _channel;

  Future<BiometricAvailability> availability() async {
    final value = await _invoke<String>('biometricAvailability');
    return switch (value) {
      'ready' => BiometricAvailability.ready,
      'not_enrolled' => BiometricAvailability.notEnrolled,
      _ => BiometricAvailability.unavailable,
    };
  }

  /// Shows the system prompt and resolves to whether it succeeded.
  ///
  /// A cancel and a failure are both `false` on purpose: the caller's next move
  /// is identical either way — leave the PIN keypad on screen and say nothing.
  Future<bool> authenticate({
    required String title,
    required String subtitle,
    required String negativeLabel,
  }) async {
    return await _invoke<bool>('biometricAuthenticate', <String, Object?>{
          'title': title,
          'subtitle': subtitle,
          'negative': negativeLabel,
        }) ??
        false;
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
      return null;
    }
  }
}
