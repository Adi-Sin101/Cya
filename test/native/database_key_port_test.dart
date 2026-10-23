import 'package:cya/native/database_key_port.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('cya/test/database-key');
  const port = DatabaseKeyPort(channel);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('native key errors cannot become a plaintext fallback', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'keystore_unavailable');
    });

    await expectLater(port.rawKey(), throwsA(isA<PlatformException>()));
    await expectLater(
      port.rawKey(encryptionRequired: false),
      throwsA(isA<PlatformException>()),
    );
  });

  test('Android rejects an absent native bridge', () async {
    await expectLater(port.rawKey(), throwsA(isA<MissingPluginException>()));
    expect(await port.rawKey(encryptionRequired: false), isNull);
  });

  test('Android rejects a null key', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    await expectLater(port.rawKey(), throwsStateError);
    expect(await port.rawKey(encryptionRequired: false), isNull);
  });

  test('only a complete raw SQLCipher key can reach the connection', () async {
    final valid = "x'${List.filled(32, 'aF').join()}'";
    messenger.setMockMethodCallHandler(channel, (_) async => valid);
    expect(await port.rawKey(), valid);

    for (final invalid in ['', "x'ab'", '$valid; PRAGMA key = 0', 'password']) {
      messenger.setMockMethodCallHandler(channel, (_) async => invalid);
      await expectLater(port.rawKey(), throwsStateError);
    }
  });
}
