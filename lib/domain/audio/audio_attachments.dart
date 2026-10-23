import 'dart:typed_data';
import 'captured_audio.dart';

abstract interface class AudioAttachments {
  Future<void> verify(CapturedAudio audio);
  Future<Uint8List> segment(CapturedAudio audio, int segment);
  Future<void> delete(String fileName);
  Future<void> eraseAll();
}
