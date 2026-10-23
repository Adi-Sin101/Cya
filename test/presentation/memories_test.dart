import 'package:cya/core/di/providers.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/drift_memory_repository.dart';
import 'package:cya/presentation/providers/memory_providers.dart';
import 'package:cya/presentation/screens/memories/memories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CyaDatabase db;
  final now = DateTime(2026, 10, 15, 14);
  setUp(() => db = CyaDatabase.memory());
  tearDown(() => db.close());
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
        ],
        child: const MaterialApp(home: MemoriesScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  testWidgets(
    'thought save commits before a dismissible chosen-priority reminder',
    (tester) async {
      await db.preferenceDao.write(focusPriorityKey, 'Finish my reading');
      await pump(tester);
      await tester.tap(find.text('Write a thought'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'কাল boi porbo');
      await tester.tap(find.text('Save thought'));
      await tester.pumpAndSettle();
      expect(find.text('কাল boi porbo'), findsOneWidget);
      expect(find.textContaining('Return to it when'), findsOneWidget);
      expect(await db.select(db.intentions).get(), isEmpty);
      expect(await db.select(db.memoryJobs).get(), hasLength(1));
      await dispose(tester);
    },
  );

  testWidgets('memory history preserves the source after editing', (
    tester,
  ) async {
    final repo = DriftMemoryRepository(db);
    final id = await repo.captureText('My original reflection', now);
    await repo.edit(id, 'A new belief', now, expectedRevision: 1);
    await pump(tester);
    await tester.scrollUntilVisible(
      find.text('A new belief').hitTestable(),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('A new belief'));
    await tester.pumpAndSettle();
    expect(find.text('Original'), findsOneWidget);
    expect(find.text('My original reflection'), findsOneWidget);
    expect(find.text('Version 2'), findsWidgets);
    await dispose(tester);
  });

  testWidgets(
    'search distinguishes Bangla vowel marks and archive is reachable',
    (tester) async {
      final repo = DriftMemoryRepository(db);
      final id = await repo.captureText('কুল fruit', now);
      await repo.captureText('কাল meeting', now);
      await repo.archive(id, true, now);
      await pump(tester);
      expect(find.text('কুল fruit'), findsNothing);
      await tester.enterText(find.byType(EditableText), 'কাল');
      await tester.pumpAndSettle();
      expect(find.text('কাল meeting'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), '');
      await tester.tap(find.byTooltip('Show archived thoughts'));
      await tester.pumpAndSettle();
      expect(find.text('কুল fruit'), findsOneWidget);
      expect(find.text('কাল meeting'), findsNothing);
      await dispose(tester);
    },
  );
}
