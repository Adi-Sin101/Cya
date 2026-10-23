// Widget tests for the Cya! app shell, reactive over a real (in-memory) store.

import 'package:cya/core/di/providers.dart';
import 'package:cya/data/dao/preference_dao.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/domain/entities/intention.dart';
import 'package:cya/domain/enums/reminder_preset.dart';
import 'package:cya/presentation/app/cya_app.dart';
import 'package:cya/presentation/shell/widgets/cya_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CyaDatabase db;
  final now = DateTime(2026, 3, 4, 18, 30);

  setUp(() async {
    db = CyaDatabase.memory();
    // These tests are about a *returning* user's app. A fresh store has no
    // onboarding flag, and the router would correctly send it to the welcome
    // flow — which is what onboarding_test.dart covers instead.
    await db.preferenceDao.write(PreferenceDao.keyOnboardingComplete, 'true');
    // Stand in for the native reminder scheduler. Its real behaviour is
    // covered in test/domain/usecases_test.dart; here it only needs to answer,
    // so the UI is never left waiting on a platform channel.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('cya/reminders'), (
          call,
        ) async {
          return switch (call.method) {
            'canScheduleExact' => true,
            'ensureNotificationPermission' => true,
            'rescheduleAll' => 0,
            // No fingerprint hardware in a test harness, and nothing this
            // suite asserts depends on one.
            'biometricAvailability' => 'unavailable',
            _ => null,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('cya/reminders'), null);
    return db.close();
  });

  Future<void> capture(String content, {bool resolved = false}) async {
    final id = await db.intentionDao.capture(
      NewIntention(
        sourceApp: 'Messenger',
        rawContent: content,
        capturedAt: now.subtract(const Duration(hours: 1)),
        reminderAt: ReminderPreset.tonight.resolve(now),
      ),
    );
    if (resolved) await db.intentionDao.resolve(id, at: now);
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          // The demo seed is a debug-build convenience, not test input.
          appStartupProvider.overrideWith((ref) async {}),
        ],
        child: const CyaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Pumps a fixed number of frames instead of settling.
  ///
  /// The Garden runs a deliberate, never-ending wind animation (PRD §8.3), so
  /// `pumpAndSettle` can never return there. Anything that navigates to the
  /// Garden has to advance time by hand.
  Future<void> pumpFrames(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  /// Tears the tree down *inside* the test body so drift's stream-cancel timers
  /// run while the tester can still pump them (otherwise flutter_test reports
  /// pending timers at teardown).
  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  testWidgets('Home renders the store contents, not a mock', (tester) async {
    await capture('Reply to Sarah', resolved: true);
    await capture('Read AI Paper');

    await pumpApp(tester);

    expect(find.textContaining('Good evening'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('promises').hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    // The hero splits the count from its noun so the number can animate.
    expect(find.text('2'), findsWidgets);
    expect(find.text('promises'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Reply to Sarah').hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Reply to Sarah'), findsOneWidget);
    expect(find.text('Memories'), findsOneWidget); // main navigation
    await disposeApp(tester);
  });

  testWidgets(
    'Rhythm has its own preserved-state tab alongside existing destinations',
    (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Rhythm'));
      await tester.pumpAndSettle();
      expect(find.text('Your rhythm'), findsOneWidget);
      expect(find.text('A day with room.'), findsOneWidget);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rhythm'));
      await tester.pumpAndSettle();
      expect(find.text('Your rhythm'), findsOneWidget);
      expect(find.bySemanticsLabel('Capture'), findsOneWidget);
      final captureBounds = tester.getRect(find.bySemanticsLabel('Capture'));
      final navBounds = tester.getRect(find.byType(CyaBottomNav));
      expect(captureBounds.right, closeTo(navBounds.right - 16, .5));
      expect(captureBounds.size, const Size(48, 48));
      expect(captureBounds.bottom, lessThan(navBounds.top));
      await disposeApp(tester);
    },
  );

  testWidgets('An empty store shows the designed empty state', (tester) async {
    await pumpApp(tester);

    await tester.scrollUntilVisible(
      find.text('promises').hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('promises'), findsOneWidget);
    expect(find.text('Nothing due. Enjoy it.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Nothing due today').hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Nothing due today'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Toggling a promise writes through and updates the ring', (
    tester,
  ) async {
    await capture('Review PR #128');
    await pumpApp(tester);

    await tester.scrollUntilVisible(
      find.text('0/1').hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('0/1'), findsOneWidget);

    // A floating corner action may overlap a row on a short viewport.
    // Verify the completion control remains reachable by scrolling.
    final toggle = find.byKey(const ValueKey<String>('promise-toggle-1'));
    await tester.scrollUntilVisible(
      toggle.hitTestable(),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(toggle);
    await pumpFrames(tester);

    final stored = await db.intentionDao.findById(1);
    expect(stored!.isResolved, isTrue);
    // A finished day stops being a fraction and says so.
    expect(find.text('all done'), findsOneWidget);
    expect(find.text('All of them. Every one.'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Returning to Home reads captures committed outside Drift', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.scrollUntilVisible(
      find.text('Nothing due today').hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Nothing due today'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    // Native capture writes the shared file without notifying Drift. Using
    // external SQL reproduces that seam without replacing the app's database.
    final seconds = now.millisecondsSinceEpoch ~/ 1000;
    await db.transaction(() async {
      await db.customStatement(
        'INSERT INTO intentions(source_app, raw_content, captured_at, '
        'updated_at, reminder_at) VALUES (?, ?, ?, ?, ?)',
        ['Shared', 'A thought captured natively', seconds, seconds, seconds],
      );
      await db.customStatement(
        'INSERT INTO intention_events(intention_id, type, occurred_at) '
        "VALUES (last_insert_rowid(), 'captured', ?)",
        [seconds],
      );
    });
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('A thought captured natively'), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Returning to a cached search includes native captures', (
    tester,
  ) async {
    await capture('Search original');
    await pumpApp(tester);
    await tester.tap(find.text('Promises').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Search');
    await tester.pumpAndSettle();
    expect(find.text('Search original'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    final seconds = now.millisecondsSinceEpoch ~/ 1000;
    await db.transaction(() async {
      await db.customStatement(
        'INSERT INTO intentions(source_app, raw_content, captured_at, '
        'updated_at, reminder_at) VALUES (?, ?, ?, ?, ?)',
        ['Shared', 'Search native addition', seconds, seconds, seconds],
      );
      await db.customStatement(
        'INSERT INTO intention_events(intention_id, type, occurred_at) '
        "VALUES (last_insert_rowid(), 'captured', ?)",
        [seconds],
      );
    });
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Search original'), findsOneWidget);
    expect(find.text('Search native addition'), findsOneWidget);
    await pumpFrames(tester);
    await disposeApp(tester);
  });

  testWidgets('Capturing from the sheet stores a promise', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('Capture'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Capture a promise'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Buy an HDMI cable');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save to Cya! ✨'));
    await tester.pumpAndSettle();

    expect(await db.intentionDao.countAll(), 1);
    await tester.scrollUntilVisible(
      find.text('Buy an HDMI cable').hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Buy an HDMI cable'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Opening a promise shows its detail actions', (tester) async {
    await capture('Reply to Sarah');
    await pumpApp(tester);

    await tester.scrollUntilVisible(
      find.text('Reply to Sarah').hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Reply to Sarah'));
    await tester.pumpAndSettle();

    expect(find.text('Mark as Done'), findsOneWidget);
    expect(find.text('Why this matters'), findsOneWidget);
    expect(find.text('Snooze'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Profile dark mode switch persists to the store', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    final switchFinder = find.byKey(
      const ValueKey<String>('profile-dark-mode-switch'),
    );
    await tester.scrollUntilVisible(
      switchFinder.hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(switchFinder)).brightness, Brightness.light);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(Theme.of(tester.element(switchFinder)).brightness, Brightness.dark);
    expect(await db.preferenceDao.read('theme_mode'), 'dark');
    await disposeApp(tester);
  });

  testWidgets('The Garden grows a plant for every promise kept', (
    tester,
  ) async {
    await capture('Reply to Sarah', resolved: true);
    await capture('Read AI Paper');
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('home-garden-preview')));
    await pumpFrames(tester);

    expect(find.text('Memory Garden'), findsOneWidget);
    expect(find.text('One new growth this week.'), findsOneWidget);
    expect(find.text('kept, all time'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('An empty Garden says so rather than showing nothing', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('home-garden-preview')));
    await pumpFrames(tester);

    expect(find.text('Bare soil, for now'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Achievements unlock from the event log', (tester) async {
    await capture('Reply to Sarah');
    await pumpApp(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    // The corner floating capture action stays visible while content scrolls.
    // Bring this lower row fully above it before tapping, as on a short screen.
    await tester.scrollUntilVisible(
      find.text('Achievements').hitTestable(),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Achievements'));
    await tester.pumpAndSettle();

    expect(find.text('1 of 6 unlocked.'), findsOneWidget);
    expect(find.text('First Step'), findsOneWidget);
    expect(find.text('Unlocked'), findsOneWidget);
    // A locked badge shows how far away it is.
    expect(find.text('0 / 100'), findsWidgets);
    await disposeApp(tester);
  });
}
