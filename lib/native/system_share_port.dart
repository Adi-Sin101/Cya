import 'package:flutter/services.dart';

/// Hands a document to the OS share sheet (PRD §9.3).
///
/// The export has to *leave* the device to be worth anything — into Drive, a
/// mail draft, a file manager — and only the user gets to choose where. So Cya!
/// writes the file to its own cache and offers it; it never picks a
/// destination, and it never uploads.
///
/// Native rather than `share_plus`, for the same reason the rest of this app's
/// platform work is native: one more package for one `ACTION_SEND` is a
/// dependency to maintain, and the channel already exists.
class SystemSharePort {
  const SystemSharePort([this._channel = _defaultChannel]);

  static const MethodChannel _defaultChannel = MethodChannel('cya/reminders');

  final MethodChannel _channel;

  /// Writes [content] to a cache file called [fileName] and opens the share
  /// sheet for it. Returns whether the sheet was shown.
  ///
  /// `false` covers a platform with no native side (tests, desktop) as well as
  /// a device with nothing that can receive a file — the caller says so rather
  /// than leaving a button that appears to do nothing.
  Future<bool> shareDocument({
    required String fileName,
    required String content,
    String mimeType = 'application/json',
    String? title,
  }) async {
    try {
      return await _channel.invokeMethod<bool>(
            'shareDocument',
            <String, Object?>{
              'fileName': fileName,
              'content': content,
              'mimeType': mimeType,
              'title': title ?? 'Your Cya! data',
            },
          ) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
