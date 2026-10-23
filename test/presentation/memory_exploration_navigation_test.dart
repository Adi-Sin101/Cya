import 'package:cya/core/di/providers.dart';
import 'package:cya/core/theme/app_theme.dart';
import 'package:cya/data/dao/preference_dao.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/drift_memory_repository.dart';
import 'package:cya/data/repositories/memory_connections.dart';
import 'package:cya/domain/entities/memory.dart';
import 'package:cya/presentation/app/cya_app.dart';
import 'package:cya/presentation/screens/memories/memory_connection_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CyaDatabase db;
  final at = DateTime(2026, 10, 16, 12);
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
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => at),
          appStartupProvider.overrideWith((ref) async {}),
        ],
        child: const CyaApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Memories'));
    await tester.pumpAndSettle();
  }

  Future<void> reveal(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(
      target.hitTestable(),
      180,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last,
    );
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  }

  testWidgets(
    'branch is reachable from main memory navigation and preserves the source',
    (tester) async {
      final repo = DriftMemoryRepository(db);
      final id = await repo.captureText('My preserved source', at);
      await pump(tester);
      await reveal(tester, find.text('Branch'));
      await tester.tap(find.text('Branch'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).last,
        'A separate exploration',
      );
      await tester.tap(find.text('Save branch'));
      await tester.pumpAndSettle();
      expect((await repo.history(id).first).single.text, 'My preserved source');
      expect(await db.select(db.memories).get(), hasLength(2));
      expect((await db.select(db.memoryLinks).get()).single.kind, 'branch');
      await dispose(tester);
    },
  );

  testWidgets(
    'accepted connections have a bounded map and navigable preserved-version list',
    (tester) async {
      final repo = DriftMemoryRepository(db);
      final id = await repo.captureText('A source thought', at);
      final target = await repo.captureText('An older linked idea', at);
      final source = (await repo.history(id).first).single;
      final linked = (await repo.history(target).first).single;
      await MemoryConnections(
        db,
      ).link(source.revisionId, linked.revisionId, 'supports', at);
      await pump(tester);
      final card = find.byKey(ValueKey('memory-$id'));
      await reveal(tester, card);
      final connections = find.descendant(
        of: card,
        matching: find.text('Connections'),
      );
      await reveal(tester, connections);
      await tester.tap(connections);
      await tester.pumpAndSettle();
      expect(find.byType(MemoryConnectionMap), findsOneWidget);
      expect(find.text('Around this thought'), findsOneWidget);
      await reveal(tester, find.textContaining('Your explicit link'));
      expect(find.textContaining('Your explicit link'), findsOneWidget);
      await reveal(tester, find.text('An older linked idea').last);
      await tester.tap(find.text('An older linked idea').last);
      await tester.pumpAndSettle();
      expect(find.text('Preserved version 1'), findsOneWidget);
      await dispose(tester);
    },
  );

  testWidgets(
    'topics and local model controls are reachable from actual memory tab',
    (tester) async {
      await pump(tester);
      await tester.tap(find.byTooltip('Local semantic model'));
      await tester.pumpAndSettle();
      expect(find.text('EmbeddingGemma 2'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Topics and projects'));
      await tester.tap(find.text('Topics and projects'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create topic or project'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My reading');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('My reading'), findsOneWidget);
      expect(
        (await db.select(db.memoryCollections).get()).single.title,
        'My reading',
      );
      await dispose(tester);
    },
  );

  testWidgets(
    'connection map stays bounded with large text and exposes every node semantically',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Memory memory(int n) => Memory(
        id: '$n',
        text: 'Thought $n',
        revisionId: 'r$n',
        revision: 1,
        capturedAt: at,
        archived: false,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.35)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: MemoryConnectionMap(
                  source: memory(0),
                  links: [for (var i = 1; i <= 20; i++) memory(i)],
                  onOpen: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('6 of 20 saved links · Full list below'),
        findsOneWidget,
      );
      expect(find.text('Thought 6'), findsOneWidget);
      expect(find.text('Thought 7'), findsNothing);
      expect(tester.takeException(), isNull);
      await dispose(tester);
    },
  );
}
