// Developer-only rendered previews with synthetic in-memory data; never a device
// performance result or a screenshot of the user's database.
// flutter test --no-pub tool/rhythm_visual_preview_test.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cya/core/di/providers.dart';
import 'package:cya/data/dao/preference_dao.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/routine_repository.dart';
import 'package:cya/presentation/app/cya_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('render synthetic ${dark ? 'dark' : 'light'} Rhythm preview', (
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
              clockProvider.overrideWithValue(() => at),
              appStartupProvider.overrideWith((ref) async {}),
            ],
            child: const CyaApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rhythm'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('.buildlog').create(recursive: true);
        await File(
          '.buildlog/rhythm-preview-${dark ? 'dark' : 'light'}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
      await db.close();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
  }
}
