import 'package:cya/core/di/providers.dart';
import 'package:cya/core/theme/app_theme.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/domain/entities/intention.dart';
import 'package:cya/presentation/screens/digest/digest_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The weekly review (PRD §5.6). It has to lead with what was kept and give the
/// user a way to close the loop from the review itself — a digest that only
/// lists what is outstanding is the guilt list §12 warns about.
void main() {
  late CyaDatabase db;
  final now = DateTime(2026, 3, 4, 18, 30);

  setUp(() {
    db = CyaDatabase.memory();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('cya/reminders'),
          (call) async => null,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('cya/reminders'), null);
    return db.close();
  });

  Future<int> capture(
    String content, {
    int snoozes = 0,
    bool kept = false,
  }) async {
    final id = await db.intentionDao.capture(
      NewIntention(
        sourceApp: 'Messenger',
        rawContent: content,
        capturedAt: now.subtract(const Duration(days: 1)),
        reminderAt: now.add(const Duration(hours: 2)),
      ),
    );
    for (var i = 0; i < snoozes; i++) {
      await db.intentionDao.snooze(
        id,
        until: now.add(const Duration(hours: 3)),
        at: now,
      );
    }
    if (kept) await db.intentionDao.resolve(id, at: now);
    return id;
  }

  Future<void> pumpDigest(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const DigestScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  testWidgets('leads with what was kept, not what is outstanding', (
    tester,
  ) async {
    await capture('Reply to Sarah', kept: true);
    await capture('Read AI Paper');
    await pumpDigest(tester);

    expect(find.text('You kept 1 promise'), findsOneWidget);
    expect(find.text('Still waiting'), findsOneWidget);
    expect(find.text('Read AI Paper'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('a promise past the snooze limit gets its own section', (
    tester,
  ) async {
    await capture('Review PR #128', snoozes: 3);
    await capture('Read AI Paper');
    await pumpDigest(tester);

    expect(find.text('Time to decide'), findsOneWidget);
    // The stalled promise is listed there, not among the ordinary waiting ones.
    expect(find.text('Review PR #128'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('a promise can be closed from the review itself', (tester) async {
    final id = await capture('Buy an HDMI cable');
    await pumpDigest(tester);

    await tester.tap(find.byKey(ValueKey<String>('promise-toggle-$id')));
    await tester.pumpAndSettle();

    expect((await db.intentionDao.findById(id))!.isResolved, isTrue);
    await disposeApp(tester);
  });

  testWidgets('an empty week is stated kindly, not as a failure', (
    tester,
  ) async {
    await pumpDigest(tester);

    expect(find.text('A quiet week'), findsOneWidget);
    expect(
      find.text('Nothing is waiting. That is a rare and good thing.'),
      findsOneWidget,
    );
    await disposeApp(tester);
  });
}
