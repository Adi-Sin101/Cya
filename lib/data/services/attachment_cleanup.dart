import '../../domain/audio/audio_attachments.dart';
import '../db/cya_database.dart';

class AttachmentCleanupService {
  AttachmentCleanupService(this.db, this.files);
  final CyaDatabase db;
  final AudioAttachments files;
  Future<void> run() async {
    while (true) {
      final batch = await (db.select(db.attachmentCleanup)..limit(50)).get();
      if (batch.isEmpty) return;
      for (final item in batch) {
        await files.delete(item.fileName);
        await (db.delete(
          db.attachmentCleanup,
        )..where((a) => a.fileName.equals(item.fileName))).go();
      }
    }
  }
}
