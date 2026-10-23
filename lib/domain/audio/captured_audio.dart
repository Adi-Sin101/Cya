import 'pcm_wave.dart';

class CapturedAudio {
  const CapturedAudio({
    required this.id,
    required this.fileName,
    required this.sha256,
    required this.byteLength,
    required this.durationMillis,
    required this.capturedAt,
  });
  final String id;
  final String fileName;
  final String sha256;
  final int byteLength;
  final int durationMillis;
  final DateTime capturedAt;

  static final _id = RegExp(
    r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$',
  );
  static bool validFileName(String fileName) =>
      fileName.length == 40 &&
      fileName.endsWith('.wav') &&
      _id.hasMatch(fileName.substring(0, fileName.length - 4));
  void validate() {
    if (id.length != 36 ||
        !_id.hasMatch(id) ||
        fileName != '$id.wav' ||
        sha256.length != 64 ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(sha256) ||
        byteLength <= 44 ||
        byteLength > PcmWave.maxDataBytes + 44 ||
        durationMillis <= 0 ||
        durationMillis > 300000) {
      throw const FormatException('Invalid local recording metadata.');
    }
  }
}
