import 'package:cya/core/di/providers.dart';
import 'package:cya/core/theme/app_theme.dart';
import 'package:cya/data/dao/preference_dao.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/domain/entities/intention.dart';
import 'package:cya/presentation/app/cya_app.dart';
import 'package:cya/presentation/screens/garden/widgets/garden_scene_view.dart';
import 'package:cya/presentation/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CyaDatabase db;
  final at = DateTime(2026, 10, 17, 10);
  setUp(() async {
    db = CyaDatabase.memory();
    await db.preferenceDao.write(PreferenceDao.keyOnboardingComplete, 'true');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('cya/reminders'),
          (call) async => switch (call.method) {
            'canScheduleExact' => true,
            'rescheduleAll' => 0,
            'biometricAvailability' => 'unavailable',
            _ => null,
          },
        );
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('cya/reminders'), null);
    await db.close();
  });
  Future<void> pump(WidgetTester tester, {bool? dark}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => at),
          appStartupProvider.overrideWith((ref) async {}),
        ],
        child: dark == null
            ? const CyaApp()
            : MaterialApp(
                theme: dark ? AppTheme.dark : AppTheme.light,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.35),
                    disableAnimations: true,
                  ),
                  child: child!,
                ),
                home: const Scaffold(body: ProfileScreen()),
              ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  Future<void> reveal(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(
      target.hitTestable(),
      140,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> gardenAndBack(WidgetTester tester, String key) async {
    final entry = find.byKey(ValueKey(key));
    await reveal(tester, entry);
    await tester.tap(entry);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Memory Garden'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
  }

  testWidgets(
    'painted Garden on Home and Profile opens full page and returns',
    (tester) async {
      await pump(tester);
      await gardenAndBack(tester, 'home-garden-preview');
      expect(find.text('Record voice'), findsOneWidget);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Your little corner.'), findsOneWidget);
      await gardenAndBack(tester, 'profile-garden-preview');
      expect(
        find.byKey(const ValueKey('profile-garden-preview')),
        findsOneWidget,
      );
      await dispose(tester);
    },
  );

  testWidgets('miniature plants and Profile milestones use real saved events', (
    tester,
  ) async {
    final id = await db.intentionDao.capture(
      NewIntention(
        sourceApp: 'QA',
        rawContent: 'A kept promise',
        capturedAt: at,
        reminderAt: at,
      ),
    );
    await pump(tester);
    Finder miniature(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(GardenSceneView),
    );
    expect(
      tester.widget<GardenSceneView>(miniature('home-garden-preview')).plants,
      isEmpty,
    );
    await db.intentionDao.resolve(id, at: at);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<GardenSceneView>(miniature('home-garden-preview'))
          .plants
          .single
          .intentionId,
      id,
    );
    expect(
      tester
          .widget<GardenSceneView>(miniature('home-garden-preview'))
          .animateWind,
      isFalse,
    );
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('1 promise kept. Still growing.'));
    expect(find.text('1 promise kept. Still growing.'), findsOneWidget);
    await reveal(tester, find.text('1 of 6 unlocked'));
    expect(find.text('1 of 6 unlocked'), findsOneWidget);
    await dispose(tester);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'visual Profile fits320px enlarged ${dark ? 'dark' : 'light'} and keeps settings reachable',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await pump(tester, dark: dark);
        expect(find.text('Your little corner.'), findsOneWidget);
        await reveal(
          tester,
          find.byKey(const ValueKey('profile-dark-mode-switch')),
        );
        expect(tester.takeException(), isNull);
        await reveal(tester, find.text('Local semantic memory'));
        expect(
          find.text('Local semantic memory').hitTestable(),
          findsOneWidget,
        );
        await dispose(tester);
      },
    );
  }
}
