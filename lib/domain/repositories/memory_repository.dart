import '../entities/memory.dart';
import '../audio/captured_audio.dart';

abstract interface class MemoryRepository {
  Stream<List<Memory>> watch({String query = '', bool archived = false});
  Future<String> captureText(String text, DateTime at);
  Future<String> captureAudio(CapturedAudio audio);
  Future<void> edit(
    String id,
    String text,
    DateTime at, {
    required int expectedRevision,
  });
  Stream<List<Memory>> history(String id);
  Future<void> archive(String id, bool archived, DateTime at);
  Future<void> deleteMemory(String id);
  Future<void> rebuildIndex();
}
