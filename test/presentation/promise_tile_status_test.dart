import 'package:cya/core/theme/app_theme.dart';
import 'package:cya/core/di/providers.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/domain/entities/intention.dart';
import 'package:cya/domain/enums/intention_status.dart';
import 'package:cya/presentation/screens/home/widgets/promise_tile.dart';
import 'package:cya/presentation/screens/promise_detail/promise_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('completed detail has no overdue reminder urgency', (
    tester,
  ) async {
    final db = CyaDatabase.memory();
    final now = DateTime(2026, 10, 23, 7);
    final id = await db.intentionDao.capture(
      NewIntention(
        sourceApp: 'Cya!',
        rawContent: 'Already kept',
        capturedAt: now.subtract(const Duration(days: 1)),
        reminderAt: now.subtract(const Duration(minutes: 3)),
      ),
    );
    await db.intentionDao.resolve(id, at: now);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: PromiseDetailScreen(intentionId: id),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Overdue'), findsNothing);
    expect(find.text('Mark as not done'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
    await db.close();
  });
  testWidgets('completion removes overdue urgency and reopening restores it', (
    tester,
  ) async {
    final now = DateTime(2026, 10, 23, 7);
    final promise = Intention(
      id: 1,
      sourceApp: 'Cya!',
      rawContent: 'A promise already kept',
      capturedAt: now.subtract(const Duration(days: 1)),
      reminderAt: now.subtract(const Duration(minutes: 3)),
      updatedAt: now,
    );
    Future<void> show(IntentionStatus status) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: PromiseTile(
                promise: promise.copyWith(status: status),
                now: now,
                onToggle: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await show(IntentionStatus.open);
    expect(find.text('Overdue'), findsOneWidget);
    await show(IntentionStatus.resolved);
    expect(find.text('Overdue'), findsNothing);
    await show(IntentionStatus.open);
    expect(find.text('Overdue'), findsOneWidget);
  });
}
