// The first-run flow (iteration 9, work item 1) and the local identity behind
// it (ADR-010).

import 'package:cya/core/di/providers.dart';
import 'package:cya/data/dao/preference_dao.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/presentation/app/cya_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CyaDatabase db;
  final now = DateTime(2026, 9, 1, 20, 30);
  late List<String> nativeCalls;

  setUp(() {
    db = CyaDatabase.memory();
    nativeCalls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('cya/reminders'), (
          call,
        ) async {
          nativeCalls.add(call.method);
          return switch (call.method) {
            'canScheduleExact' => true,
            'ensureNotificationPermission' => true,
            'rescheduleAll' => 0,
            'biometricAvailability' => 'unavailable',
            'deviceReliability' => <String, Object?>{
              'oem': 'xiaomi',
              'manufacturer': 'Xiaomi',
              'osLabel': 'HyperOS',
              'batteryUnrestricted': false,
              'exactAlarms': true,
              'notifications': true,
            },
            _ => null,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('cya/reminders'), null);
    return db.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    // A phone, not the 800x600 default. These screens are portrait-first and
    // one of them is a keypad; measuring them in a landscape box would prove
    // nothing about the device they ship on.
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          appStartupProvider.overrideWith((ref) async {}),
        ],
        child: const CyaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The share-gesture demo loops forever by design, so `pumpAndSettle` can
  /// never return once it is on screen (PRD §8.3 — the same reason the Garden
  /// needs this). Advance by hand instead.
  Future<void> pumpFrames(WidgetTester tester, {int frames = 14}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> tapAndAdvance(WidgetTester tester, String label) async {
    // Onboarding steps scroll when the content is taller than the window, so
    // the action may legitimately be below the fold.
    await tester.ensureVisible(find.text(label));
    await tester.pump();
    await tester.tap(find.text(label));
    await pumpFrames(tester);
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  group('a fresh install', () {
    testWidgets('opens on onboarding rather than Home', (tester) async {
      await pumpApp(tester);

      expect(find.text("I'll remember for you."), findsOneWidget);
      // Not the app: a user who has never seen the share sheet is the failure
      // this flow exists to prevent.
      expect(find.text('Good Evening'), findsNothing);

      await dispose(tester);
    });

    testWidgets('teaches the share gesture before asking for anything', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapAndAdvance(tester, 'Next');

      expect(find.text('Save it without leaving the app.'), findsOneWidget);
      expect(
        find.textContaining('tap Share and pick Cya!'),
        findsOneWidget,
      );
      // Nothing has been asked of the user yet.
      expect(nativeCalls, isNot(contains('ensureNotificationPermission')));

      await dispose(tester);
    });

    testWidgets('asks for notifications only after showing what they are for', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapAndAdvance(tester, 'Next');
      await tapAndAdvance(tester, 'Got it');

      // The reason is on screen: the actual reminder, Done and Snooze included.
      expect(find.text('Reply to Sarah'), findsWidgets);
      expect(find.text('Done'), findsWidgets);
      expect(find.text('Snooze'), findsWidgets);
      expect(nativeCalls, isNot(contains('ensureNotificationPermission')));

      await tapAndAdvance(tester, 'Allow notifications');
      expect(nativeCalls, contains('ensureNotificationPermission'));

      await dispose(tester);
    });

    testWidgets('"Not now" is a real way past the permission', (tester) async {
      await pumpApp(tester);
      await tapAndAdvance(tester, 'Next');
      await tapAndAdvance(tester, 'Got it');
      await tapAndAdvance(tester, 'Not now');

      expect(nativeCalls, isNot(contains('ensureNotificationPermission')));
      expect(find.textContaining('switches'), findsOneWidget);

      await dispose(tester);
    });
  });

  group('the reliability step', () {
    testWidgets('names the device and lists what it got wrong', (tester) async {
      await pumpApp(tester);
      await tapAndAdvance(tester, 'Next');
      await tapAndAdvance(tester, 'Got it');
      await tapAndAdvance(tester, 'Not now');

      expect(find.text('Detected: Xiaomi · HyperOS'), findsOneWidget);
      // Autostart appears because this is a Xiaomi; a stock device would not
      // see a row it could never tick.
      expect(find.text('Autostart'), findsOneWidget);
      expect(find.text('Battery'), findsOneWidget);
      // Exact alarms are already granted in this fixture, so that row is done
      // and the battery row is not.
      expect(find.text('Open'), findsWidgets);

      await dispose(tester);
    });

    testWidgets('opening autostart records it, since nothing reports it back', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapAndAdvance(tester, 'Next');
      await tapAndAdvance(tester, 'Got it');
      await tapAndAdvance(tester, 'Not now');

      await tester.tap(find.text('Open').first);
      await pumpFrames(tester);

      expect(nativeCalls, contains('openAutostartSettings'));
      expect(
        await db.preferenceDao.read(PreferenceDao.keyAutostartConfirmed),
        'true',
      );

      await dispose(tester);
    });
  });

  group('local identity', () {
    Future<void> reachProfile(WidgetTester tester) async {
      await pumpApp(tester);
      await tapAndAdvance(tester, 'Next');
      await tapAndAdvance(tester, 'Got it');
      await tapAndAdvance(tester, 'Not now');
      await tapAndAdvance(tester, "I've done these — finish setup");
    }

    testWidgets('profile setup offers no account, only a name', (tester) async {
      await reachProfile(tester);

      expect(find.text('What should I call you?'), findsOneWidget);
      expect(
        find.text('This profile never leaves your phone.'),
        findsOneWidget,
      );
      // The things a server-backed sign-up would have, and this one must not.
      expect(find.textContaining('Password'), findsNothing);
      expect(find.textContaining('Email'), findsNothing);
      expect(find.textContaining('Continue with'), findsNothing);

      await dispose(tester);
    });

    testWidgets('the name and avatar are written to the local store', (
      tester,
    ) async {
      await reachProfile(tester);

      await tester.enterText(find.byType(TextField), 'Arif');
      await tester.tap(find.bySemanticsLabel('Moon'));
      await pumpFrames(tester);
      await tapAndAdvance(tester, 'Continue');

      expect(
        await db.preferenceDao.read(PreferenceDao.keyDisplayName),
        'Arif',
      );
      expect(await db.preferenceDao.read(PreferenceDao.keyAvatar), 'moon');

      await dispose(tester);
    });

    testWidgets('the lock step is honest that there is no PIN reset', (
      tester,
    ) async {
      await reachProfile(tester);
      await tapAndAdvance(tester, 'Continue');

      expect(find.text('Lock your promises?'), findsOneWidget);
      expect(
        find.textContaining("there's no PIN reset"),
        findsOneWidget,
      );

      await dispose(tester);
    });

    testWidgets('setting a PIN requires typing it twice', (tester) async {
      await reachProfile(tester);
      await tapAndAdvance(tester, 'Continue');

      for (final digit in <String>['4', '8', '2', '1']) {
        await tester.tap(find.bySemanticsLabel(digit));
        await pumpFrames(tester, frames: 2);
      }
      expect(find.text('Type it once more'), findsOneWidget);

      // A mismatch throws both away rather than storing the first.
      for (final digit in <String>['9', '9', '9', '9']) {
        await tester.tap(find.bySemanticsLabel(digit));
        await pumpFrames(tester, frames: 2);
      }
      expect(find.text("Those didn't match. Start again."), findsOneWidget);
      expect(await db.preferenceDao.read(PreferenceDao.keyPinHash), isNull);

      await dispose(tester);
    });

    testWidgets('skipping the lock still finishes setup and opens the app', (
      tester,
    ) async {
      await reachProfile(tester);
      await tapAndAdvance(tester, 'Continue');
      await tapAndAdvance(tester, 'Skip — no lock');

      expect(
        await db.preferenceDao.read(PreferenceDao.keyOnboardingComplete),
        'true',
      );
      expect(await db.preferenceDao.read(PreferenceDao.keyPinHash), isNull);
      // And the flow is not repeatable: onboarding is behind us.
      expect(find.text("I'll remember for you."), findsNothing);

      await dispose(tester);
    });
  });

  testWidgets('a returning user never sees onboarding again', (tester) async {
    await db.preferenceDao.write(PreferenceDao.keyOnboardingComplete, 'true');

    await pumpApp(tester);

    expect(find.text("I'll remember for you."), findsNothing);

    await dispose(tester);
  });
}
