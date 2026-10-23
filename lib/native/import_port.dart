import 'package:flutter/services.dart';

class ImportPort {
  const ImportPort();
  static const _channel = MethodChannel('cya/imports');
  Future<Map<String, Object?>?> pick() =>
      _channel.invokeMapMethod<String, Object?>('pick');
  Future<void> copy(
    String token,
    List<Map<String, Object?>> attachments,
  ) async {
    if (await _channel.invokeMethod<bool>('copyAttachments', {
          'token': token,
          'attachments': attachments,
        }) !=
        true) {
      throw StateError('Original attachments could not be restored.');
    }
  }

  Future<void> finish(String token) =>
      _channel.invokeMethod<void>('finish', {'token': token});
}
