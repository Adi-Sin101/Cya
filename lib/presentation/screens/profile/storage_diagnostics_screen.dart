import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/di/providers.dart';
import '../../widgets/local_feature_header.dart';

final localStorageSnapshotProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  final db = ref.watch(databaseProvider),
      root = await getApplicationSupportDirectory(),
      cache = await getTemporaryDirectory();
  final counts = <String, int>{};
  for (final entry in {
    'Saved thoughts': 'memories',
    'Preserved thought versions': 'memory_revisions',
    'Linked audio originals': 'memory_attachments',
    'Routine definitions (including removed)': 'routines',
    'Selected routine occurrences': 'routine_occurrences',
    'Review notes': 'local_reviews',
    'Pending audio cleanup': 'attachment_cleanup',
  }.entries) {
    counts[entry.key] =
        (await db
                .customSelect('SELECT COUNT(*) AS count FROM ${entry.value}')
                .getSingle())
            .read<int>('count');
  }
  counts['Index jobs waiting / retrying'] =
      (await db
              .customSelect(
                "SELECT COUNT(*) AS count FROM memory_jobs WHERE state != 'complete'",
              )
              .getSingle())
          .read<int>('count');
  Future<int> bytes(Directory directory) async {
    if (!await directory.exists()) return 0;
    var total = 0;
    await for (final entry in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entry is File) {
        try {
          total += (await entry.stat()).size;
        } on FileSystemException {
          /* A concurrent bounded job may remove a cache file. */
        }
      }
    }
    return total;
  }

  var database = 0;
  for (final suffix in ['', '-wal', '-shm']) {
    final file = File('${root.path}/cya.db$suffix');
    if (await file.exists()) database += await file.length();
  }
  counts['Database bytes (including journal files)'] = database;
  counts['Original audio bytes'] = await bytes(
    Directory('${root.path}/memory_audio'),
  );
  counts['Installed local model bytes'] = await bytes(
    Directory('${root.path}/memory_models'),
  );
  counts['Prepared backup cache bytes'] = await bytes(
    Directory('${cache.path}/exports'),
  );
  return counts;
});

class StorageDiagnosticsScreen extends ConsumerWidget {
  const StorageDiagnosticsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('Local storage and status'),
      actions: [
        IconButton(
          onPressed: () => ref.invalidate(localStorageSnapshotProvider),
          tooltip: 'Refresh local snapshot',
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const LocalFeatureHeader(
          icon: Icons.storage_rounded,
          title: 'A home for your memories.',
          description: 'A snapshot of what is saved on this device.',
        ),
        ref
            .watch(localStorageSnapshotProvider)
            .when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text(
                'Could not read a complete snapshot. Check storage availability and retry; this does not change your data.',
              ),
              data: (values) => Column(
                children: [
                  for (final entry in values.entries)
                    LocalCountTile(
                      label: entry.key,
                      icon: entry.key.contains('bytes')
                          ? Icons.sd_storage_outlined
                          : Icons.inventory_2_outlined,
                      value: entry.key.contains('bytes')
                          ? _size(entry.value)
                          : entry.value.toString(),
                    ),
                ],
              ),
            ),
        const SizedBox(height: 16),
        const Text(
          'Original recordings and shared backups are readable files, not encrypted. Database protection is separate. A snapshot is not a backup.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Index jobs wait safely when the model is missing or paused. Resume or rebuild from Memories → Local semantic model. Capture and keyword search remain available.',
        ),
      ],
    ),
  );
}

String _size(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}
