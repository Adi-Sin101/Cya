import 'package:flutter/services.dart';

/// Fetches the shared store's encryption key from the native side (ADR-010).
///
/// Kotlin owns the key because Kotlin owns the Android Keystore, and because
/// the Share Sheet capture path has to open the same file with no Flutter
/// engine running at all. Dart is the *second* reader here, not the owner.
///
/// The key crosses the method channel and no further. There is no `INTERNET`
/// permission in the manifest, so there is nowhere for it to go.
class DatabaseKeyPort {
  const DatabaseKeyPort([this._channel = _defaultChannel]);

  static const MethodChannel _defaultChannel = MethodChannel('cya/reminders');

  final MethodChannel _channel;

  /// The raw key in SQLCipher's `x'<64 hex>'` form, or `null` where there is no
  /// native side.
  ///
  /// `null` is a real answer, not a failure: `flutter test` and the desktop
  /// builds have no Keystore and no encrypted file, and refusing to open at all
  /// there would trade a security property this app cannot provide off-device
  /// for a test suite that cannot run.
  Future<String?> rawKey() async {
    try {
      return await _channel.invokeMethod<String>('databaseKey');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
