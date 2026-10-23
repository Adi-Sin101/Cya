import 'package:flutter/services.dart';

/// Fetches the shared store's encryption key from the native side (ADR-010).
///
/// Kotlin owns the key because Kotlin owns the Android Keystore, and because
/// the Share Sheet capture path has to open the same file with no Flutter
/// engine running at all. Dart is the *second* reader here, not the owner.
///
/// The key crosses the local method channel to configure the shared store.
class DatabaseKeyPort {
  const DatabaseKeyPort([this._channel = _defaultChannel]);

  static const MethodChannel _defaultChannel = MethodChannel('cya/reminders');

  final MethodChannel _channel;

  /// Android must fail closed. Unsupported hosts may explicitly permit a
  /// missing native implementation; an actual native error always propagates.
  Future<String?> rawKey({bool encryptionRequired = true}) async {
    final String? key;
    try {
      key = await _channel.invokeMethod<String>('databaseKey');
    } on MissingPluginException {
      if (encryptionRequired) rethrow;
      return null;
    }
    if (key == null && !encryptionRequired) return null;
    if (key == null ||
        key.length != 67 ||
        !RegExp(r"^x'[0-9a-fA-F]{64}'$").hasMatch(key)) {
      throw StateError(
        'The native store did not provide a valid database key.',
      );
    }
    return key;
  }
}
