import 'package:cya/core/di/providers.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/routine_repository.dart';
import 'package:cya/presentation/screens/routines/day_plan_screen.dart';
import 'package:cya/presentation/screens/routines/review_screen.dart';
import 'package:cya/presentation/screens/routines/routines_screen.dart';
import 'package:cya/presentation/screens/routines/rhythm_week_chart.dart';
import 'package:cya/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CyaDatabase db;
  final at = DateTime(2026, 10, 16, 12);
  setUp(() => db = CyaDatabase.memory());
  tearDown(() => db.close());
  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => at),
        ],
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  for (final dark in [false, true]) {
    testWidgets(
      'visual rhythm fits narrow enlarged ${dark ? 'dark' : 'light'} mode without motion',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              clockProvider.overrideWithValue(() => at),
            ],
            child: MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1.35),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: const DayPlanScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Your rhythm'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView).first, const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await dispose(tester);
      },
    );
  }
  testWidgets('weekly graphic uses selected plans and explicit outcomes', (
    tester,
  ) async {
    final repo = RoutineRepository(db);
    final id = await repo.save(
      expectedRevision: 0,
      title: 'Read',
      steps: [],
      at: at,
    );
    final occurrence = await repo.select(id, at, at);
    await repo.change(occurrence, at, expectedVersion: 1, state: 'completed');
    await pump(tester, Scaffold(body: RhythmWeekChart(day: at)));
    expect(find.text('1 selected · 1 completed'), findsOneWidget);
    expect(await db.select(db.routineOccurrenceEvents).get(), hasLength(2));
    await dispose(tester);
  });

  testWidgets(
    'routine builder creates a definition without automatically filling Today',
    (tester) async {
      await pump(tester, const RoutinesScreen());
      await tester.tap(find.text('Create routine'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Routine name'),
        'My flexible routine',
      );
      await tester.scrollUntilVisible(
        find.text('Save routine'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Save routine'));
      await tester.pumpAndSettle();
      expect(find.text('My flexible routine'), findsOneWidget);
      expect(await db.select(db.routines).get(), hasLength(1));
      expect(await db.select(db.routineOccurrences).get(), isEmpty);
      expect(await db.select(db.routineEvents).get(), hasLength(1));
      await dispose(tester);
    },
  );
  testWidgets('day selection and completion require explicit user actions', (
    tester,
  ) async {
    await RoutineRepository(db).save(
      expectedRevision: 0,
      title: 'Read one page',
      steps: ['Open my book'],
      at: at,
    );
    await pump(tester, const DayPlanScreen());
    expect(await db.select(db.routineOccurrences).get(), isEmpty);
    final choose = find.text('Choose a routine');
    await tester.scrollUntilVisible(
      choose.hitTestable(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(choose);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Read one page'),
      150,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Read one page'));
    await tester.pumpAndSettle();
    expect(
      (await db.select(db.routineOccurrences).get()).single.state,
      'planned',
    );
    final complete = find.byTooltip('Mark completed');
    await tester.scrollUntilVisible(
      complete.hitTestable(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(complete);
    await tester.pumpAndSettle();
    expect(
      (await db.select(db.routineOccurrences).get()).single.state,
      'completed',
    );
    expect(await db.select(db.routineOccurrenceEvents).get(), hasLength(2));
    expect(await db.select(db.intentions).get(), isEmpty);
    await dispose(tester);
  });
  testWidgets(
    'review is optional and saving a note does not alter routine outcomes',
    (tester) async {
      final repo = RoutineRepository(db),
          id = await repo.save(
            expectedRevision: 0,
            title: 'Selected routine',
            steps: [],
            at: at,
          );
      final selected = await repo.select(id, at, at);
      await repo.change(selected, at, expectedVersion: 1, state: 'completed');
      await pump(tester, ReviewScreen(day: at));
      expect(find.text('completed: 1'), findsOneWidget);
      expect(await db.select(db.localReviews).get(), isEmpty);
      final field = find.byType(TextField);
      await tester.scrollUntilVisible(field, 250);
      await tester.enterText(field, 'A short note about what helped.');
      await tester.pump();
      final save = find.text('Save optional note');
      await tester.scrollUntilVisible(
        save,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(
        (await db.select(db.memoryRevisions).get()).single.body,
        'A short note about what helped.',
      );
      expect(await db.select(db.memoryJobs).get(), hasLength(1));
      expect(
        (await db.select(db.routineOccurrences).get()).single.state,
        'completed',
      );
      expect(await db.select(db.routineEvents).get(), hasLength(1));
      await dispose(tester);
    },
  );
}
