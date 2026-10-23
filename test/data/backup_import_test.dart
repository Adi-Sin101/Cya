import 'dart:convert';
import 'dart:io';

import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/drift_memory_repository.dart';
import 'package:cya/data/services/backup_import.dart';
import 'package:cya/data/services/local_audio_files.dart';
import 'package:cya/domain/services/data_export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CyaDatabase source;
  late CyaDatabase target;
  late Directory root;
  late LocalAudioFiles files;
  setUp(() async {
    source = CyaDatabase.memory();
    target = CyaDatabase.memory();
    root = await Directory.systemTemp.createTemp('cya-import-test-');
    files = LocalAudioFiles(directory: () async => root);
  });
  tearDown(() async {
    await source.close();
    await target.close();
    await root.delete(recursive: true);
  });
  Future<Map<String, Object?>> snapshot() async {
    final repo = DriftMemoryRepository(source);
    final at = DateTime(2026, 10, 16);
    final id = await repo.captureText('Original reflection', at);
    await repo.edit(id, 'My new decision', at, expectedRevision: 1);
    return DataExport.build(
      exportedAt: at,
      intentions: [],
      events: [],
      preferences: {'display_name': 'Do not overwrite'},
      memories: [
        for (final m in await source.select(source.memories).get()) m.toJson(),
      ],
      memoryRevisions: [
        for (final r in await source.select(source.memoryRevisions).get())
          r.toJson(),
      ],
      memoryEvents: [
        for (final e in await source.select(source.memoryEvents).get())
          e.toJson(),
      ],
    );
  }

  test(
    'append remaps identities, preserves immutable history and queues fresh jobs',
    () async {
      final document = await snapshot();
      final existing = await DriftMemoryRepository(
        target,
      ).captureText('Already here', DateTime(2026));
      await target.preferenceDao.write('display_name', 'Current name');
      final backup = BackupImport.parse(jsonEncode(document));
      await backup.append(
        target,
        files: files,
        copyAttachments: (rows) async => expect(rows, isEmpty),
      );
      expect(await target.select(target.memories).get(), hasLength(2));
      final revisions = await target.select(target.memoryRevisions).get();
      expect(
        revisions.map((r) => r.body),
        containsAll(['Original reflection', 'My new decision', 'Already here']),
      );
      expect(
        revisions
            .where((r) => r.memoryId != existing)
            .map((r) => r.id)
            .toSet()
            .intersection(backup.revisions.map((r) => r.id).toSet()),
        isEmpty,
      );
      expect(await target.select(target.memoryJobs).get(), hasLength(3));
      expect(await target.preferenceDao.read('display_name'), 'Current name');
      await expectLater(
        backup.append(target, files: files, copyAttachments: (_) async {}),
        throwsStateError,
      );
      expect(await target.select(target.memories).get(), hasLength(2));
    },
  );
  test(
    'unknown versions, dangling references, duplicate revisions and mismatched counts reject before writes',
    () async {
      final document = await snapshot();
      Map<String, dynamic> fresh() =>
          jsonDecode(jsonEncode(document)) as Map<String, dynamic>;
      final badVersion = fresh()..['formatVersion'] = 99;
      expect(
        () => BackupImport.parse(jsonEncode(badVersion)),
        throwsFormatException,
      );
      final dangling = fresh();
      dangling['memoryRevisions'][0]['memoryId'] = 'missing';
      expect(
        () => BackupImport.parse(jsonEncode(dangling)),
        throwsFormatException,
      );
      final duplicate = fresh();
      duplicate['memoryRevisions'][1]['revision'] = 1;
      expect(
        () => BackupImport.parse(jsonEncode(duplicate)),
        throwsFormatException,
      );
      final counts = fresh();
      counts['counts']['memories'] = 0;
      expect(
        () => BackupImport.parse(jsonEncode(counts)),
        throwsFormatException,
      );
      expect(await target.select(target.memories).get(), isEmpty);
    },
  );
  test(
    'failed history transaction leaves no new source, jobs or import marker',
    () async {
      final backup = BackupImport.parse(jsonEncode(await snapshot()));
      await target.customStatement(
        "CREATE TRIGGER reject_import BEFORE INSERT ON memory_events BEGIN SELECT RAISE(ABORT,'fixture'); END",
      );
      await expectLater(
        backup.append(target, files: files, copyAttachments: (_) async {}),
        throwsA(anything),
      );
      expect(await target.select(target.memories).get(), isEmpty);
      expect(await target.select(target.memoryRevisions).get(), isEmpty);
      expect(await target.select(target.memoryJobs).get(), isEmpty);
      expect(
        await target.preferenceDao.read(
          'imported_backup_${backup.fingerprint}',
        ),
        isNull,
      );
    },
  );
}
