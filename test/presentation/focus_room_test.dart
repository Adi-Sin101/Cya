import 'package:cya/core/di/providers.dart';
import 'package:cya/core/theme/app_theme.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/focus_timer_repository.dart';
import 'package:cya/data/repositories/routine_repository.dart';
import 'package:cya/presentation/screens/routines/focus_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CyaDatabase db;
  late DateTime now;
  setUp(() => {db = CyaDatabase.memory(), now = DateTime(2026, 10, 16, 12)});
  tearDown(() => db.close());
  Future<void> pump(
    WidgetTester tester, {
    double scale = 1,
    bool reduced = false,
    String priority = 'Read a page',
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              disableAnimations: reduced,
            ),
            child: child!,
          ),
          home: FocusRoomScreen(priority: priority),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  testWidgets('a focus priority needs no routine or promise', (tester) async {
    await pump(tester, priority: '');
    await tester.enterText(find.byType(TextField), 'Write a paper');
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Begin focus').hitTestable(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Begin focus'));
    await tester.pumpAndSettle();
    expect((await FocusTimerRepository(db).load())!.priority, 'Write a paper');
    expect(await db.select(db.intentions).get(), isEmpty);
    expect(await db.select(db.routineOccurrences).get(), isEmpty);
    await dispose(tester);
  });
  testWidgets(
    'reopened focus restores its saved routine steps and completion action',
    (tester) async {
      final routines = RoutineRepository(db);
      final routineId = await routines.save(
        expectedRevision: 0,
        title: 'Read a page',
        steps: ['Open the book', 'Read slowly'],
        at: now,
      );
      final occurrenceId = await routines.select(routineId, now, now);
      await FocusTimerRepository(
        db,
      ).start('Read a page', 15, now, occurrenceId: occurrenceId);
      // Reopening via the day header supplies the priority, not a route argument
      // containing the occurrence. Its durable ID is the source of truth.
      await pump(tester);
      await tester.scrollUntilVisible(
        find.text('Complete routine & finish'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Complete routine & finish'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Read slowly'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Open the book'), findsOneWidget);
      expect(
        (await db.select(db.routineOccurrences).get()).single.state,
        'planned',
      );
      await dispose(tester);
    },
  );
  testWidgets(
    'focus starts only by choice, pauses and resumes a durable clock',
    (tester) async {
      await pump(tester);
      expect(await FocusTimerRepository(db).load(), isNull);
      await tester.scrollUntilVisible(
        find.text('Begin focus'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Begin focus'));
      await tester.pumpAndSettle();
      expect((await FocusTimerRepository(db).load())!.durationSeconds, 1500);
      now = now.add(const Duration(minutes: 2));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('23:00'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Pause'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();
      expect((await FocusTimerRepository(db).load())!.running, isFalse);
      now = now.add(const Duration(minutes: 5));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('23:00'), findsOneWidget);
      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      expect((await FocusTimerRepository(db).load())!.running, isTrue);
      expect(await db.select(db.routineOccurrences).get(), isEmpty);
      await dispose(tester);
    },
  );
  testWidgets(
    'focus capture saves original text before showing selected-priority reminder',
    (tester) async {
      await FocusTimerRepository(db).start('Read a page', 25, now);
      await pump(tester);
      await tester.tap(find.byTooltip('Save a thought'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        '  Keep this original thought.  ',
      );
      await tester.tap(find.text('Save thought'));
      await tester.pumpAndSettle();
      expect(
        (await db.select(db.memoryRevisions).get()).single.body,
        '  Keep this original thought.  ',
      );
      expect(await db.select(db.memoryJobs).get(), hasLength(1));
      expect(find.textContaining('Return to it when'), findsOneWidget);
      await dispose(tester);
    },
  );
  testWidgets('narrow enlarged dark focus works with reduced motion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pump(tester, scale: 1.35, reduced: true);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Begin focus'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    await dispose(tester);
  });
}
