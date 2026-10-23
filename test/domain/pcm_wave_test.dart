import 'dart:typed_data';
import 'package:cya/domain/audio/pcm_wave.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'PCM wrapper preserves exact original sample bytes and declared format',
    () {
      final pcm = Uint8List.fromList([0, 0, 255, 127, 0, 128, 1, 0]);
      final wav = PcmWave.wrap(pcm);
      expect(wav.sublist(44), pcm);
      expect(
        PcmWave.validateHeader(wav.sublist(0, 44), wav.length),
        pcm.length,
      );
    },
  );
  test('truncation, wrong sample rate and oversized data are rejected', () {
    final wav = PcmWave.wrap(Uint8List(32000));
    expect(
      () => PcmWave.validateHeader(wav.sublist(0, 43), wav.length),
      throwsFormatException,
    );
    expect(
      () => PcmWave.validateHeader(wav.sublist(0, 44), wav.length - 1),
      throwsFormatException,
    );
    ByteData.sublistView(wav).setUint32(24, 44100, Endian.little);
    expect(
      () => PcmWave.validateHeader(wav.sublist(0, 44), wav.length),
      throwsFormatException,
    );
    expect(() => PcmWave.wrap(Uint8List(3)), throwsFormatException);
    expect(
      () => PcmWave.wrap(Uint8List(PcmWave.maxDataBytes + 2)),
      throwsFormatException,
    );
  });
}
