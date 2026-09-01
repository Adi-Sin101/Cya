// The data-layer half of ADR-014 and PRD §9.3.

import 'package:cya/data/db/cya_database.dart';
import 'package:cya/domain/entities/intention.dart';
import 'package:cya/domain/enums/intention_event_type.dart';
import 'package:cya/domain/enums/intention_status.dart';
import 'package:cya/domain/policies/aging_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CyaDatabase db;
  final now = DateTime(2026, 9, 1, 20, 30);

  setUp(() => db = CyaDatabase.memory());
  tearDown(() => db.close());

  Future<int> capture({
    required Duration ago,
    String content = 'Reply to Sarah',
  }) async {
    final at = now.subtract(ago);
    return db.intentionDao.capture(
      NewIntention(
        sourceApp: 'Messenger',
        rawContent: content,
        capturedAt: at,
        reminderAt: at.add(const Duration(hours: 4)),
      ),
    );
  }

  Future<List<int>> retire() => db.intentionDao.retireStale(
    cutoff: AgingPolicy.cutoffFrom(now),
    at: now,
    reason: AgingPolicy.reason,
  );

  group('retiring stale promises (ADR-014)', () {
    test('archives only what has aged out', () async {
      final old = await capture(ago: const Duration(days: 45));
      final fresh = await capture(ago: const Duration(days: 2));

      expect(await retire(), <int>[old]);

      expect((await db.intentionDao.findById(old))!.status,
          IntentionStatus.archived);
      expect(
        (await db.intentionDao.findById(fresh))!.status,
        IntentionStatus.open,
      );
    });

    test('records why, so the log can tell it from a user archiving', () async {
      final id = await capture(ago: const Duration(days: 45));
      await retire();

      final events = await db.intentionDao.watchEventsFor(id).first;
      final archived = events.singleWhere(
        (e) => e.type == IntentionEventType.archived,
      );
      expect(archived.metadata, contains(AgingPolicy.reason));
    });

    test('a resolved promise is never retired', () async {
      final id = await capture(ago: const Duration(days: 90));
      await db.intentionDao.resolve(id, at: now.subtract(const Duration(days: 80)));

      expect(await retire(), isEmpty);
      expect(
        (await db.intentionDao.findById(id))!.status,
        IntentionStatus.resolved,
      );
    });

    test('is idempotent — a second sweep retires nothing', () async {
      await capture(ago: const Duration(days: 45));
      expect(await retire(), hasLength(1));
      expect(await retire(), isEmpty);
    });

    test('the digest can find what was retired, and only that', () async {
      final aged = await capture(ago: const Duration(days: 45));
      final byHand = await capture(ago: const Duration(days: 1));
      await db.intentionDao.archive(byHand, at: now);
      await retire();

      final retired = await db.intentionDao
          .watchRetiredSince(
            now.subtract(const Duration(days: 14)),
            AgingPolicy.reason,
          )
          .first;

      // Both are archived; only one was retired *by the calendar*, and only
      // that one gets offered back.
      expect(retired.map((p) => p.id), <int>[aged]);
    });
  });

  group('export and erase (§9.3)', () {
    test('export includes archived promises', () async {
      await capture(ago: const Duration(days: 1));
      final gone = await capture(ago: const Duration(days: 2));
      await db.intentionDao.archive(gone, at: now);

      // "Everything" has to mean everything, or it is a summary the vendor
      // curated.
      expect(await db.intentionDao.allForExport(), hasLength(2));
      expect(await db.intentionDao.allEventsForExport(), hasLength(3));
    });

    test('erase leaves nothing behind', () async {
      await capture(ago: const Duration(days: 1));
      await capture(ago: const Duration(days: 2));

      await db.intentionDao.eraseEverything();

      expect(await db.intentionDao.allForExport(), isEmpty);
      expect(await db.intentionDao.allEventsForExport(), isEmpty);
    });

    test('erase leaves the search index consistent, not haunted', () async {
      await capture(ago: const Duration(days: 1), content: 'Ghost promise');
      expect(await db.intentionDao.search('ghost'), hasLength(1));

      await db.intentionDao.eraseEverything();
      expect(await db.intentionDao.search('ghost'), isEmpty);

      // And a promise captured afterwards is findable — the index was rebuilt,
      // not merely emptied.
      await capture(ago: Duration.zero, content: 'Fresh promise');
      expect(await db.intentionDao.search('fresh'), hasLength(1));
    });
  });
}
