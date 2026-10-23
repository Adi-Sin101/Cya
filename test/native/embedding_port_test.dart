import 'dart:io';
import 'dart:math';

import 'package:cya/domain/services/embedding_runtime.dart';
import 'package:cya/native/embedding_port.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('cya/test/embeddings');
  const port = EmbeddingPort(channel);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'unsupported host keeps capture usable without pretending the model exists',
    () async {
      expect(await port.installed(), isFalse);
      await expectLater(
        port.text('text'),
        throwsA(isA<MissingPluginException>()),
      );
    },
  );
  test(
    'invalid dimension, NaN and zero vectors cannot enter the local index',
    () async {
      for (final vector in [
        <double>[1],
        List.filled(256, 0.0),
        List.filled(256, double.nan),
      ]) {
        messenger.setMockMethodCallHandler(channel, (_) async => vector);
        await expectLater(port.text('text'), throwsStateError);
      }
    },
  );
  test(
    'raw WAV is forwarded independently of any text and normalized consistently',
    () async {
      final wav = Uint8List.fromList([82, 73, 70, 70]);
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'embedAudio');
        expect((call.arguments as Map).keys, ['wav']);
        expect((call.arguments as Map)['wav'], wav);
        return List.filled(256, 2.0);
      });
      final vector = await port.audio(wav);
      expect(
        sqrt(vector.fold<double>(0, (sum, v) => sum + v * v)),
        closeTo(1, 0.000001),
      );
    },
  );
  test('native install hash matches the versioned Dart index artifact pin', () {
    final kotlin = File(
      'android/app/src/main/kotlin/dev/cya/app/memory/EmbeddingBridge.kt',
    ).readAsStringSync();
    final pin = RegExp(
      'const val SHA256 = "([a-f0-9]+)"',
    ).firstMatch(kotlin)!.group(1);
    expect(pin, EmbeddingRuntime.modelHash);
  });
}
