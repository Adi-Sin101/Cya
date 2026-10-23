// Developer-only rendered previews with synthetic in-memory data; never a device
// performance result or a screenshot of the user's database.
// flutter test --no-pub tool/journal_visual_preview_test.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cya/core/di/providers.dart';
import 'package:cya/data/dao/preference_dao.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/routine_repository.dart';
import 'package:cya/data/repositories/drift_memory_repository.dart';
import 'package:cya/domain/audio/captured_audio.dart';
import 'package:cya/domain/audio/audio_attachments.dart';
import 'package:cya/domain/audio/pcm_wave.dart';
import 'package:cya/domain/entities/intention.dart';
import 'package:cya/presentation/app/cya_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Files implements AudioAttachments {
  @override
  Future<void> verify(CapturedAudio audio) async => audio.validate();
  @override
  Future<Uint8List> segment(CapturedAudio audio, int segment) async =>
      PcmWave.wrap(Uint8List(PcmWave.bytesPerSecond));
  @override
  Future<void> delete(String fileName) async {}
  @override
  Future<void> eraseAll() async {}
}

void main() {
  for (final dark in [false, true]) {
    testWidgets('render synthetic ${dark ? 'dark' : 'light'} journal previews', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final loader = FontLoader('PlusJakartaSans');
      for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
        loader.addFont(
          rootBundle.load('lib/assets/fonts/PlusJakartaSans-$weight.ttf'),
        );
      }
      await loader.load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      final db = CyaDatabase.memory(), at = DateTime(2026, 10, 16, 10);
      await db.preferenceDao.write(PreferenceDao.keyOnboardingComplete, 'true');
      await db.preferenceDao.write(
        PreferenceDao.keyThemeMode,
        dark ? 'dark' : 'light',
      );
      final files = _Files();
      final memories = DriftMemoryRepository(db, audioFiles: files);
      await memories.captureText(
        'The best ideas arrive when I give them room. Keep a little space for reading tomorrow.',
        at,
      );
      await memories.captureAudio(
        CapturedAudio(
          id: '12345678-1234-4234-8234-123456789abc',
          fileName: '12345678-1234-4234-8234-123456789abc.wav',
          sha256: 'a' * 64,
          byteLength: PcmWave.bytesPerSecond * 42 + 44,
          durationMillis: 42000,
          capturedAt: at,
        ),
      );
      const voice = MethodChannel('cya/audio');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            voice,
            (call) async => call.method == 'pending' ? <Object>[] : null,
          );
      for (var i = 0; i < 3; i++) {
        final id = await db.intentionDao.capture(
          NewIntention(
            sourceApp: 'QA',
            rawContent: 'Synthetic promise $i',
            capturedAt: at.subtract(const Duration(days: 3)),
            reminderAt: at,
          ),
        );
        await db.intentionDao.resolve(
          id,
          at: at.subtract(Duration(days: i + 1)),
        );
      }
      final repo = RoutineRepository(db);
      for (final entry in [
        ('Morning reset', ['Make a little space', 'Choose one priority'], 450),
        ('Read, think, write', ['Open the notebook', 'Follow one idea'], 600),
        (
          'A softer evening',
          ['Put the day down', 'Keep a thought for tomorrow'],
          1230,
        ),
      ]) {
        final id = await repo.save(
          expectedRevision: 0,
          title: entry.$1,
          steps: entry.$2,
          start: entry.$3,
          at: at,
        );
        final occurrence = await repo.select(id, at, at);
        if (entry.$1 == 'Morning reset') {
          await repo.change(
            occurrence,
            at,
            expectedVersion: 1,
            state: 'completed',
          );
        }
      }
      const channel = MethodChannel('cya/reminders');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (call) async => switch (call.method) {
              'canScheduleExact' => true,
              'rescheduleAll' => 0,
              'biometricAvailability' => 'unavailable',
              _ => null,
            },
          );
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              audioAttachmentsProvider.overrideWithValue(files),
              clockProvider.overrideWithValue(() => at),
              appStartupProvider.overrideWith((ref) async {}),
            ],
            child: const CyaApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> snapshot(String name) async {
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('.buildlog').create(recursive: true);
          await File(
            '.buildlog/journal-$name-${dark ? 'dark' : 'light'}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await snapshot('home');
      await tester.tap(find.text('Memories'));
      await snapshot('library');
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -480));
      await snapshot('entries');
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 1200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Record voice'));
      await snapshot('recorder');
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await snapshot('profile');
      await tester.drag(find.byType(ListView).last, const Offset(0, -280));
      await snapshot('profile-progress');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
      await db.close();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(voice, null);
    });
  }
}
