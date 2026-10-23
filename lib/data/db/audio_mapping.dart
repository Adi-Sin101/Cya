import '../../domain/audio/captured_audio.dart';
import 'cya_database.dart';

extension AudioAttachmentMapping on MemoryAttachmentRow {
  CapturedAudio toCapturedAudio() => CapturedAudio(
    id: id,
    fileName: fileName,
    sha256: sha256,
    byteLength: byteLength,
    durationMillis: durationMillis,
    capturedAt: capturedAt,
  );
}
