import 'package:cya/core/di/providers.dart';
import 'package:cya/core/theme/app_theme.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/domain/entities/intention.dart';
import 'package:cya/presentation/providers/today_provider.dart';
import 'package:cya/presentation/screens/garden/garden_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CyaDatabase db;

  setUp(() {
    db = CyaDatabase.memory();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('cya/reminders'), (
          call,
        ) async {
          return switch (call.method) {
            'canScheduleExact' => true,
            'ensureNotificationPermission' => true,
            'rescheduleAll' => 0,
            _ => null,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('cya/reminders'), null);
    return db.close();
  });

  group('midnight rollover', () {
    test('the day advances on its own, with no user interaction', () {
      // 23:59:30. The app is open and nobody is going to touch it.
      var now = DateTime(2026, 3, 4, 23, 59, 30);

      FakeAsync().run((async) {
        final container = ProviderContainer(
          overrides: <Override>[
            databaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(() => now),
          ],
        );

        expect(container.read(todayProvider), DateTime(2026, 3, 4));

        // The wall clock crosses midnight while the app sits idle.
        now = DateTime(2026, 3, 5, 0, 0, 5);
        async.elapse(const Duration(seconds: 45));

        expect(
          container.read(todayProvider),
          DateTime(2026, 3, 5),
          reason: 'the rollover timer fired without anything else happening',
        );

        // And it keeps going: the notifier re-arms for the following night
        // rather than rolling over once and going quiet.
        now = DateTime(2026, 3, 6, 0, 0, 5);
        async.elapse(const Duration(days: 1));
        expect(container.read(todayProvider), DateTime(2026, 3, 6));

        // Disposed inside the zone that owns its timer.
        container.dispose();
      });
    });
  });

  group('reduced motion', () {
    /// Renders the app with the platform's "disable animations" flag set, the
    /// way an accessibility setting does (PRD §8.3/§8.4).
    Future<void> pumpCalm(WidgetTester tester, Widget child) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            databaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(() => DateTime(2026, 3, 4, 18, 30)),
            appStartupProvider.overrideWith((ref) async {}),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('the Garden settles instead of animating forever', (
      tester,
    ) async {
      await db.intentionDao.resolve(
        await db.intentionDao.capture(
          NewIntention(
            sourceApp: 'Messenger',
            rawContent: 'Reply to Sarah',
            capturedAt: DateTime(2026, 3, 4, 12),
            reminderAt: DateTime(2026, 3, 4, 20),
          ),
        ),
        at: DateTime(2026, 3, 4, 13),
      );

      await pumpCalm(tester, const GardenScreen());

      // The decisive assertion: with motion reduced, the endless wind ticker
      // never starts, so the tree can actually settle. Under normal motion
      // this call would time out — which is exactly the difference a
      // reduced-motion user is asking for.
      await tester.pumpAndSettle();

      expect(find.text('Memory Garden'), findsOneWidget);
      expect(find.text('kept, all time'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
    });
  });
}
