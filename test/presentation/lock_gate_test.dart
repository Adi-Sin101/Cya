// The unlock gate: what a locked device shows, and what opens it (ADR-010).

import 'package:cya/core/di/providers.dart';
import 'package:cya/data/dao/preference_dao.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/preference_lock_repository.dart';
import 'package:cya/domain/entities/intention.dart';
import 'package:cya/domain/enums/reminder_preset.dart';
import 'package:cya/presentation/app/cya_app.dart';
import 'package:cya/presentation/providers/identity_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CyaDatabase db;
  final now = DateTime(2026, 9, 1, 20, 30);

  setUp(() async {
    db = CyaDatabase.memory();
    await db.preferenceDao.write(PreferenceDao.keyOnboardingComplete, 'true');
    await db.preferenceDao.write(PreferenceDao.keyDisplayName, 'Arif');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('cya/reminders'), (
          call,
        ) async {
          return switch (call.method) {
            'canScheduleExact' => true,
            'ensureNotificationPermission' => true,
            'rescheduleAll' => 0,
            // Assert the PIN path: a harness that auto-passes a fingerprint
            // would never exercise the keypad at all.
            'biometricAvailability' => 'unavailable',
            'biometricAuthenticate' => false,
            _ => null,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('cya/reminders'), null);
    return db.close();
  });

  /// A repository whose hashing runs inline and cheaply.
  ///
  /// `testWidgets` runs inside a fake-async zone, and a future that resolves on
  /// another isolate never completes there — so the app's real strategy would
  /// hang the moment a PIN was checked. The policy under test (verdicts,
  /// cooldowns, what the screen says) is identical either way; the cost itself
  /// is asserted in pin_hasher_test.dart.
  PreferenceLockRepository lockRepository() => PreferenceLockRepository(
    db.preferenceDao,
    () => now,
    iterations: 64,
    worker: PreferenceLockRepository.inlineWorker,
  );

  /// Locks the store with [pin], the same way the setup screen would.
  Future<void> setPin(String pin) => lockRepository().setPin(pin);

  Future<void> pumpApp(WidgetTester tester) async {
    // Phone-shaped, but wider than a real 360dp handset: `flutter test`
    // substitutes a fallback font that draws roughly one em per glyph, so
    // Home's header measures far wider here than Plus Jakarta Sans does on a
    // device. Home renders behind the lock in every one of these tests, and a
    // font artefact in a screen that is not under test should not fail them.
    tester.view.physicalSize = const Size(540, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          appStartupProvider.overrideWith((ref) async {}),
          lockRepositoryProvider.overrideWith((ref) => lockRepository()),
        ],
        child: const CyaApp(),
      ),
    );
    // Frames rather than `pumpAndSettle`: the app is still live behind the
    // lock, and the Garden preview's ambient motion never settles (PRD §8.3).
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }
  }

  Future<void> type(WidgetTester tester, String pin) async {
    for (final digit in pin.split('')) {
      await tester.tap(find.bySemanticsLabel(digit));
      await tester.pump(const Duration(milliseconds: 60));
    }
    // Let the verification settle and the screen react.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  testWidgets('a device with no PIN opens straight into the app', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Welcome back'), findsNothing);

    await dispose(tester);
  });

  testWidgets('a locked device greets before it challenges', (tester) async {
    await setPin('4821');
    await pumpApp(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Arif'), findsOneWidget);
    // No recovery link, because there is no recovery. Offering one would be a
    // lie the setup screen already refused to tell.
    expect(find.textContaining('Forgot'), findsNothing);

    await dispose(tester);
  });

  testWidgets('the promises behind the lock stay behind it', (tester) async {
    await db.intentionDao.capture(
      NewIntention(
        sourceApp: 'Messenger',
        rawContent: 'Reply to Sarah about the deck',
        capturedAt: now.subtract(const Duration(hours: 2)),
        reminderAt: ReminderPreset.tonight.resolve(now),
      ),
    );
    await setPin('4821');

    final semantics = tester.ensureSemantics();
    await pumpApp(tester);

    // Home is resolved behind the gate — that is what makes a notification
    // deep link survive being locked — so the widget is in the tree.
    expect(find.text('Reply to Sarah about the deck'), findsWidgets);

    // But nothing of it reaches a screen reader.
    final labels = <String>[];
    void collect(SemanticsNode node) {
      labels
        ..add(node.label)
        ..add(node.value);
      node.visitChildren((child) {
        collect(child);
        return true;
      });
    }

    collect(tester.getSemantics(find.byType(MaterialApp).first));
    expect(labels.join(' | '), isNot(contains('Reply to Sarah')));

    // And it cannot be reached by touch: the overlay absorbs the tap rather
    // than letting it fall through to the promise underneath.
    await tester.tap(
      find.text('Reply to Sarah about the deck').first,
      warnIfMissed: false,
    );
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Mark as Done'), findsNothing);

    semantics.dispose();
    await dispose(tester);
  });

  testWidgets('the right PIN opens the app', (tester) async {
    await setPin('4821');
    await pumpApp(tester);

    await type(tester, '4821');

    expect(find.text('Welcome back'), findsNothing);

    await dispose(tester);
  });

  testWidgets('a wrong PIN says so and leaves the lock up', (tester) async {
    await setPin('4821');
    await pumpApp(tester);

    await type(tester, '9999');

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.textContaining('Not quite'), findsOneWidget);
    // And the dots are cleared, ready for another try.
    expect(find.text('0 of 4 digits entered'), findsNothing);

    await dispose(tester);
  });

  testWidgets('too many wrong PINs starts a visible cooldown', (tester) async {
    await setPin('4821');
    await pumpApp(tester);

    for (var attempt = 0; attempt < 5; attempt++) {
      await type(tester, '9999');
    }

    expect(find.textContaining('Too many tries'), findsOneWidget);

    await dispose(tester);
  });
}
