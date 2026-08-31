// Widget tests for the Cya! app shell, reactive over a real (in-memory) store.

import 'package:cya/core/di/providers.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/domain/entities/intention.dart';
import 'package:cya/domain/enums/reminder_preset.dart';
import 'package:cya/presentation/app/cya_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CyaDatabase db;
  final now = DateTime(2026, 3, 4, 18, 30);

  setUp(() => db = CyaDatabase.memory());
  tearDown(() => db.close());

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

    expect(find.textContaining('Good Evening'), findsOneWidget);
    expect(find.text('2 promises'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('Reply to Sarah'), findsOneWidget);
    expect(find.text('Garden'), findsWidgets); // bottom nav
    await disposeApp(tester);
  });

  testWidgets('An empty store shows the designed empty state', (tester) async {
    await pumpApp(tester);

    expect(find.text('0 promises'), findsOneWidget);
    expect(find.text('Nothing due today'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Toggling a promise writes through and updates the ring', (
    tester,
  ) async {
    await capture('Review PR #128');
    await pumpApp(tester);

    expect(find.text('0/1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('promise-toggle-1')));
    await tester.pumpAndSettle();

    final stored = await db.intentionDao.findById(1);
    expect(stored!.isResolved, isTrue);
    expect(find.text('1/1'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Capturing from the sheet stores a promise', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Buy an HDMI cable');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save to Cya! ✨'));
    await tester.pumpAndSettle();

    expect(await db.intentionDao.countAll(), 1);
    expect(find.text('Buy an HDMI cable'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Opening a promise shows its detail actions', (tester) async {
    await capture('Reply to Sarah');
    await pumpApp(tester);

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
    expect(Theme.of(tester.element(switchFinder)).brightness, Brightness.light);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(Theme.of(tester.element(switchFinder)).brightness, Brightness.dark);
    expect(await db.preferenceDao.read('theme_mode'), 'dark');
    await disposeApp(tester);
  });
}
