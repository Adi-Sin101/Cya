import 'dart:convert';
import 'dart:typed_data';

/// The original recording format, independent of transcription or a model.
abstract final class PcmWave {
  static const sampleRate = 16000;
  static const bytesPerSecond = sampleRate * 2;
  static const headerBytes = 44;
  static const segmentSeconds = 20;
  static const segmentBytes = bytesPerSecond * segmentSeconds;
  static const maxDataBytes = bytesPerSecond * 300;

  static Uint8List wrap(Uint8List pcm) {
    if (pcm.length.isOdd || pcm.length > maxDataBytes) {
      throw const FormatException('Unsupported PCM length.');
    }
    final out = Uint8List(headerBytes + pcm.length);
    final data = ByteData.sublistView(out);
    void tag(int at, String text) =>
        out.setRange(at, at + text.length, ascii.encode(text));
    tag(0, 'RIFF');
    data.setUint32(4, 36 + pcm.length, Endian.little);
    tag(8, 'WAVE');
    tag(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(28, bytesPerSecond, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    tag(36, 'data');
    data.setUint32(40, pcm.length, Endian.little);
    out.setRange(headerBytes, out.length, pcm);
    return out;
  }

  static int validateHeader(Uint8List header, int fileBytes) {
    if (header.length < headerBytes) {
      throw const FormatException('Incomplete recording header.');
    }
    final data = ByteData.sublistView(header);
    bool tag(int at, String text) =>
        ascii.decode(
          header.sublist(at, at + text.length),
          allowInvalid: true,
        ) ==
        text;
    final length = data.getUint32(40, Endian.little);
    if (!tag(0, 'RIFF') ||
        !tag(8, 'WAVE') ||
        !tag(12, 'fmt ') ||
        !tag(36, 'data') ||
        data.getUint32(16, Endian.little) != 16 ||
        data.getUint16(20, Endian.little) != 1 ||
        data.getUint16(22, Endian.little) != 1 ||
        data.getUint32(24, Endian.little) != sampleRate ||
        data.getUint32(28, Endian.little) != bytesPerSecond ||
        data.getUint16(32, Endian.little) != 2 ||
        data.getUint16(34, Endian.little) != 16 ||
        data.getUint32(4, Endian.little) != length + 36 ||
        length == 0 ||
        length.isOdd ||
        length > maxDataBytes ||
        fileBytes != length + headerBytes) {
      throw const FormatException(
        'Recording is incomplete, corrupted or uses an unsupported format.',
      );
    }
    return length;
  }
}
