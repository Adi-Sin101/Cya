import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/drift_intention_repository.dart';
import 'package:cya/domain/entities/intention.dart';
import 'package:cya/domain/enums/promise_category.dart';
import 'package:cya/domain/services/reminder_scheduler.dart';
import 'package:cya/domain/usecases/manage_intention.dart';
import 'package:flutter_test/flutter_test.dart';

/// Manual categories (PRD §6.4). The wire values are stored, so they are part
/// of the contract that on-device auto-categorization will later write into.
void main() {
  late CyaDatabase db;
  final now = DateTime(2026, 3, 4, 14);

  setUp(() => db = CyaDatabase.memory());
  tearDown(() => db.close());

  Future<int> capture() => db.intentionDao.capture(
    NewIntention(
      sourceApp: 'Messenger',
      rawContent: 'Reply to Sarah',
      capturedAt: now,
      reminderAt: now.add(const Duration(hours: 4)),
    ),
  );

  test('every category round-trips through its wire value', () {
    for (final category in PromiseCategory.values) {
      expect(PromiseCategory.fromWire(category.wire), category);
    }
  });

  test('an unknown or missing category shows nothing rather than guessing', () {
    expect(PromiseCategory.fromWire(null), isNull);
    expect(PromiseCategory.fromWire('sometime-later-category'), isNull);
  });

  test('categorizing stores the wire value and logs an edit', () async {
    final id = await capture();
    final manage = ManageIntention(
      DriftIntentionRepository(db.intentionDao),
      () => now,
      const NoopReminderScheduler(),
    );

    await manage.categorize(id, PromiseCategory.reply.wire);

    final stored = (await db.intentionDao.findById(id))!;
    expect(stored.category, 'reply');
    expect(PromiseCategory.fromWire(stored.category), PromiseCategory.reply);

    final events = await db.intentionDao.watchEventsFor(id).first;
    expect(events.last.metadata, contains('"change":"category"'));
  });

  test('clearing a category is as easy as setting one', () async {
    final id = await capture();
    final manage = ManageIntention(
      DriftIntentionRepository(db.intentionDao),
      () => now,
      const NoopReminderScheduler(),
    );

    await manage.categorize(id, PromiseCategory.read.wire);
    await manage.categorize(id, null);

    expect((await db.intentionDao.findById(id))!.category, isNull);
  });
}
