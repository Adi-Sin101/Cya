import 'dart:convert';
import 'dart:io';

import 'package:cya/core/di/providers.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/drift_memory_repository.dart';
import 'package:cya/data/services/local_audio_files.dart';
import 'package:cya/presentation/providers/privacy_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'existing export and erase controls include thoughts and immutable history',
    () async {
      final db = CyaDatabase.memory();
      final root = await Directory.systemTemp.createTemp('cya-privacy-test-');
      addTearDown(() => root.delete(recursive: true));
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          audioAttachmentsProvider.overrideWithValue(
            LocalAudioFiles(directory: () async => root),
          ),
        ],
      );
      addTearDown(db.close);
      addTearDown(container.dispose);
      Map<String, dynamic>? document;
      const channel = MethodChannel('cya/reminders');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'shareDocument') {
          document =
              jsonDecode((call.arguments as Map)['content'] as String)
                  as Map<String, dynamic>;
          return true;
        }
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      final repo = DriftMemoryRepository(db);
      final at = DateTime(2026, 10, 15);
      final id = await repo.captureText('My original', at);
      await repo.edit(id, 'My changed view', at, expectedRevision: 1);
      await db.preferenceDao.write('lock_pin_hash', 'NEVER_EXPORT');
      await container.read(privacyControllerProvider).exportEverything();
      expect(document!['formatVersion'], 8);
      expect(document!['memories'], hasLength(1));
      expect((document!['memoryRevisions'] as List).map((r) => r['body']), [
        'My original',
        'My changed view',
      ]);
      expect(document!['memoryEvents'], hasLength(2));
      expect(jsonEncode(document), isNot(contains('NEVER_EXPORT')));
      final erased = await container
          .read(privacyControllerProvider)
          .eraseEverything();
      expect(erased.isSuccess, isTrue, reason: '${erased.errorOrNull}');
      expect(await db.select(db.memories).get(), isEmpty);
      expect(await db.select(db.memoryRevisions).get(), isEmpty);
      expect(await db.select(db.memoryJobs).get(), isEmpty);
    },
  );
}
