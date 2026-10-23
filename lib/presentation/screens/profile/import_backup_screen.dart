import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../data/services/backup_import.dart';
import '../../../native/import_port.dart';
import '../../providers/memory_providers.dart';
import '../../widgets/local_feature_header.dart';

BackupImport _parseBackup(Map<String, Object?> value) => BackupImport.parse(
  value['manifest']! as String,
  files: (value['files']! as List).cast<String>(),
);

class ImportBackupScreen extends ConsumerStatefulWidget {
  const ImportBackupScreen({super.key});
  @override
  ConsumerState<ImportBackupScreen> createState() => _ImportBackupState();
}

class _ImportBackupState extends ConsumerState<ImportBackupScreen> {
  final _port = const ImportPort();
  BackupImport? _backup;
  String? _token;
  String? _message;
  bool _busy = false;
  bool _imported = false;
  Future<void> _select() async {
    setState(() {
      _busy = true;
      _message = null;
      _backup = null;
    });
    try {
      if (_token != null) {
        await _port.finish(_token!);
        _token = null;
      }
      await ref.read(semanticIndexProvider).pause();
      final value = await _port.pick();
      if (value == null) return;
      final token = value['token']! as String;
      _token = token;
      final backup = await compute(_parseBackup, value);
      if (!mounted) {
        await _port.finish(token);
        _token = null;
        return;
      }
      _backup = backup;
    } on Object {
      _message =
          'Could not validate this backup. Check its version, records and attachments. Existing data is unchanged.';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final backup = _backup;
    final token = _token;
    if (backup == null || token == null || _busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await backup.append(
        ref.read(databaseProvider),
        files: ref.read(audioAttachmentsProvider),
        copyAttachments: (rows) => _port.copy(token, rows),
      );
      _imported = true;
      _message =
          'Backup imported as new copies. Original history and audio are preserved. Semantic indexing will resume when you open Memories.';
      await ref.read(reminderPortProvider).rescheduleAll();
    } on Object {
      _message = _imported
          ? 'Data imported. Reminder rescheduling did not finish. Reopen Cya! to retry scheduling.'
          : 'Import did not finish. It may be a repeated backup or invalid attachment. Check saved data before retrying; existing records were not overwritten.';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    final token = _token;
    if (token != null) {
      _port.finish(token).catchError((Object _) {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('Import a backup')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const LocalFeatureHeader(
            icon: Icons.drive_folder_upload_outlined,
            title: 'Bring your memories home.',
            description:
                'Choose a local Cya! backup. Add validated copies without overwriting what is here.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Import adds new copies. Current records, settings, PIN and model configuration stay as they are. Reimporting the exact same backup is blocked. Imported active focus sessions are ended with a recorded import event. Backups are readable files, not encrypted.',
          ),
          const SizedBox(height: 24),
          if (!_imported)
            OutlinedButton.icon(
              onPressed: _busy ? null : _select,
              icon: const Icon(Icons.folder_open),
              label: const Text('Choose local backup'),
            ),
          if (_busy) const LinearProgressIndicator(),
          if (_backup case final backup?) ...[
            const SizedBox(height: 24),
            for (final item in [
              (
                'Promises',
                backup.intentions.length,
                Icons.bookmark_outline_rounded,
              ),
              ('Memories', backup.memories.length, Icons.auto_stories_outlined),
              (
                'Preserved versions',
                backup.revisions.length,
                Icons.history_rounded,
              ),
              (
                'Original recordings',
                backup.attachments.length,
                Icons.mic_rounded,
              ),
              (
                'Focus sessions',
                backup.focusSessions.length,
                Icons.center_focus_strong_rounded,
              ),
              (
                'Routines',
                backup.routineData.routines.length,
                Icons.wb_twilight_rounded,
              ),
              (
                'Selected activities',
                backup.routineData.occurrences.length,
                Icons.route_outlined,
              ),
              (
                'Review notes',
                backup.routineData.reviews.length,
                Icons.edit_note_rounded,
              ),
            ])
              LocalCountTile(
                label: item.$1,
                value: item.$2.toString(),
                icon: item.$3,
              ),
            const SizedBox(height: 8),
            const Text(
              'Plans retain their dates. Imported active focus sessions are ended; your current priority stays unchanged.',
            ),
            const SizedBox(height: 16),
            if (!_imported)
              FilledButton(
                onPressed: _busy ? null : _restore,
                child: const Text('Import as new copies'),
              ),
          ],
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(_message!, semanticsLabel: _message),
            ),
        ],
      ),
    ),
  );
}
