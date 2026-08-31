import 'package:drift/drift.dart';

import '../../domain/entities/intention.dart';
import '../../domain/entities/intention_event.dart';
import '../../domain/enums/intention_event_type.dart';
import '../../domain/enums/intention_status.dart';
import '../db/cya_database.dart';
import '../db/mappers.dart';
import '../db/tables.dart';

part 'intention_dao.g.dart';

/// All SQL for intentions and their event log.
///
/// **Invariant:** no method here mutates an intention without appending the
/// matching event *in the same transaction* (PRD §7.1). If a write is not worth
/// an event, it is not a state change.
@DriftAccessor(tables: [Intentions, IntentionEvents])
class IntentionDao extends DatabaseAccessor<CyaDatabase>
    with _$IntentionDaoMixin {
  IntentionDao(super.db);

  // ---------------------------------------------------------------- queries

  /// Today's Promises (PRD §8.2): everything still due by the end of today —
  /// including anything overdue — plus what was already resolved today, so the
  /// completion ring reflects the day's real work.
  Stream<List<Intention>> watchToday(DateTime dayStart, DateTime dayEnd) {
    final query = select(intentions)
      ..where(
        (t) =>
            t.status.isNotValue(IntentionStatus.archived.wire) &
            t.reminderAt.isSmallerOrEqualValue(dayEnd) &
            (t.status.isNotValue(IntentionStatus.resolved.wire) |
                t.updatedAt.isBiggerOrEqualValue(dayStart)),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.reminderAt),
        (t) => OrderingTerm(expression: t.capturedAt),
      ]);
    return query.watch().map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  /// Every promise that has not been archived, newest capture first.
  Stream<List<Intention>> watchAllActive() {
    final query = select(intentions)
      ..where((t) => t.status.isNotValue(IntentionStatus.archived.wire))
      ..orderBy([
        (t) => OrderingTerm(expression: t.capturedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  Stream<Intention?> watchById(int id) {
    final query = select(intentions)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull().map((row) => row?.toEntity());
  }

  Future<Intention?> findById(int id) async {
    final query = select(intentions)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row?.toEntity();
  }

  /// Pending promises whose reminder has come due — the scheduler's work list.
  Future<List<Intention>> dueAt(DateTime instant) async {
    final query = select(intentions)
      ..where(
        (t) =>
            t.status.isIn([
              IntentionStatus.open.wire,
              IntentionStatus.snoozed.wire,
            ]) &
            t.reminderAt.isSmallerOrEqualValue(instant),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.reminderAt)]);
    final rows = await query.get();
    return rows.map((r) => r.toEntity()).toList();
  }

  /// The next reminder that needs an alarm scheduled, if any.
  Future<Intention?> nextScheduled(DateTime after) async {
    final query = select(intentions)
      ..where(
        (t) =>
            t.status.isIn([
              IntentionStatus.open.wire,
              IntentionStatus.snoozed.wire,
            ]) &
            t.reminderAt.isBiggerThanValue(after),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.reminderAt)])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row?.toEntity();
  }

  /// On-device full-text search over captured content (PRD §6.4).
  ///
  /// The index is reconciled first, because the native capture path writes rows
  /// without touching it (ADR-005).
  Future<List<Intention>> search(String rawQuery) async {
    final term = _toMatchQuery(rawQuery);
    if (term == null) return const <Intention>[];
    // Promises captured natively while the app was closed are not in the index
    // yet — Dart owns it (ADR-005).
    await attachedDatabase.reconcileSearchIndex();
    final rows = await customSelect(
      'SELECT i.* FROM intentions_fts f '
      'JOIN intentions i ON i.id = f.rowid '
      "WHERE intentions_fts MATCH ?1 AND i.status != 'archived' "
      'ORDER BY rank',
      variables: [Variable<String>(term)],
      readsFrom: {intentions},
    ).get();
    return rows
        .map((row) => intentions.map(row.data).toEntity())
        .toList(growable: false);
  }

  /// Turns user input into a safe FTS5 prefix query. Returns `null` when the
  /// input has no searchable token.
  static String? _toMatchQuery(String rawQuery) {
    final tokens = rawQuery
        .toLowerCase()
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((token) => token.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return null;
    return tokens.map((token) => '"$token"*').join(' ');
  }

  /// Promises whose reminder time has passed with **no `resurfaced` event** —
  /// alarms the OS never delivered (PRD §12: OEM battery optimization silently
  /// dropping reminders is the risk that would quietly kill a memory product).
  ///
  /// Measured rather than assumed: because every fired reminder writes an
  /// event, their absence is evidence.
  Future<List<Intention>> missedReminders(
    DateTime now, {
    Duration grace = const Duration(minutes: 10),
  }) async {
    final cutoff = now.subtract(grace).millisecondsSinceEpoch ~/ 1000;
    final rows = await customSelect(
      'SELECT i.* FROM intentions i '
      "WHERE i.status IN ('open', 'snoozed') "
      'AND i.reminder_at IS NOT NULL AND i.reminder_at <= ?1 '
      'AND NOT EXISTS ('
      '  SELECT 1 FROM intention_events e '
      "  WHERE e.intention_id = i.id AND e.type = 'resurfaced' "
      '  AND e.occurred_at >= i.reminder_at'
      ') ORDER BY i.reminder_at',
      variables: [Variable<int>(cutoff)],
      readsFrom: {intentions, intentionEvents},
    ).get();
    return rows
        .map((row) => intentions.map(row.data).toEntity())
        .toList(growable: false);
  }

  // ----------------------------------------------------------- event log

  Stream<List<IntentionEvent>> watchEventsSince(DateTime since) {
    final query = select(intentionEvents)
      ..where((t) => t.occurredAt.isBiggerOrEqualValue(since))
      ..orderBy([(t) => OrderingTerm(expression: t.occurredAt)]);
    return query.watch().map((rows) => rows.toEntities());
  }

  Stream<List<IntentionEvent>> watchEventsFor(int intentionId) {
    final query = select(intentionEvents)
      ..where((t) => t.intentionId.equals(intentionId))
      ..orderBy([(t) => OrderingTerm(expression: t.occurredAt)]);
    return query.watch().map((rows) => rows.toEntities());
  }

  /// Lifetime event counts per type — the narrow aggregate that XP and levels
  /// project from, so the UI never streams the whole log (PRD §9.1).
  Stream<Map<IntentionEventType, int>> watchEventCounts() {
    return customSelect(
      'SELECT type, COUNT(*) AS c FROM intention_events GROUP BY type',
      readsFrom: {intentionEvents},
    ).watch().map((rows) {
      final counts = <IntentionEventType, int>{};
      for (final row in rows) {
        final type = IntentionEventType.tryFromWire(row.read<String>('type'));
        if (type != null) counts[type] = row.read<int>('c');
      }
      return counts;
    });
  }

  // ----------------------------------------------------------- mutations

  /// The capture write: one row + one `captured` event, nothing else
  /// (PRD §3.2). Mirrors what the native writer does natively.
  Future<int> capture(NewIntention capture) {
    return transaction(() async {
      final id = await into(intentions).insert(
        IntentionsCompanion.insert(
          sourceApp: capture.sourceApp,
          rawContent: capture.rawContent,
          snippet: Value(capture.snippet),
          deepLink: Value(capture.deepLink),
          capturedAt: capture.capturedAt,
          reminderAt: Value(capture.reminderAt),
          updatedAt: capture.capturedAt,
        ),
      );
      await _logEvent(
        intentionId: id,
        type: IntentionEventType.captured,
        occurredAt: capture.capturedAt,
        metadata: '{"source":"${capture.sourceApp}"}',
      );
      return id;
    });
  }

  Future<void> resolve(int id, {required DateTime at}) {
    return _transition(
      id,
      at: at,
      status: IntentionStatus.resolved,
      event: IntentionEventType.resolved,
    );
  }

  /// Undo a resolution (the Home toggle is two-way). Logged as an edit so the
  /// log stays a faithful history rather than pretending it never happened.
  Future<void> reopen(int id, {required DateTime at}) {
    return _transition(
      id,
      at: at,
      status: IntentionStatus.open,
      event: IntentionEventType.edited,
      metadata: '{"change":"reopened"}',
    );
  }

  Future<void> archive(int id, {required DateTime at}) {
    return _transition(
      id,
      at: at,
      status: IntentionStatus.archived,
      event: IntentionEventType.archived,
    );
  }

  /// Push a promise out to [until] and count the snooze. The snooze *limit*
  /// is a domain policy (PRD §5.6) enforced above this layer; the DAO records
  /// what happened.
  Future<void> snooze(int id, {required DateTime until, required DateTime at}) {
    return transaction(() async {
      final row = await (select(
        intentions,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) return;
      await (update(intentions)..where((t) => t.id.equals(id))).write(
        IntentionsCompanion(
          status: Value(IntentionStatus.snoozed.wire),
          reminderAt: Value(until),
          snoozeCount: Value(row.snoozeCount + 1),
          updatedAt: Value(at),
        ),
      );
      await _logEvent(
        intentionId: id,
        type: IntentionEventType.snoozed,
        occurredAt: at,
        metadata:
            '{"until":"${until.toIso8601String()}",'
            '"count":${row.snoozeCount + 1}}',
      );
    });
  }

  /// Records that a reminder was actually shown — the input to escalation
  /// (PRD §5.6) and to reminder-reliability measurement (§9.2).
  Future<void> markResurfaced(int id, {required DateTime at, String? tier}) {
    return transaction(() async {
      await (update(intentions)..where((t) => t.id.equals(id))).write(
        IntentionsCompanion(updatedAt: Value(at)),
      );
      await _logEvent(
        intentionId: id,
        type: IntentionEventType.resurfaced,
        occurredAt: at,
        metadata: tier == null ? null : '{"tier":"$tier"}',
      );
    });
  }

  Future<void> updateReminder(int id, DateTime? reminderAt, DateTime at) {
    return transaction(() async {
      await (update(intentions)..where((t) => t.id.equals(id))).write(
        IntentionsCompanion(
          reminderAt: Value(reminderAt),
          status: Value(IntentionStatus.open.wire),
          updatedAt: Value(at),
        ),
      );
      await _logEvent(
        intentionId: id,
        type: IntentionEventType.edited,
        occurredAt: at,
        metadata: '{"change":"reminder"}',
      );
    });
  }

  Future<void> updateCategory(int id, String? category, DateTime at) {
    return transaction(() async {
      await (update(intentions)..where((t) => t.id.equals(id))).write(
        IntentionsCompanion(category: Value(category), updatedAt: Value(at)),
      );
      await _logEvent(
        intentionId: id,
        type: IntentionEventType.edited,
        occurredAt: at,
        metadata: '{"change":"category"}',
      );
    });
  }

  Future<void> updateContent(int id, String rawContent, DateTime at) {
    return transaction(() async {
      await (update(intentions)..where((t) => t.id.equals(id))).write(
        IntentionsCompanion(
          rawContent: Value(rawContent),
          updatedAt: Value(at),
        ),
      );
      await _logEvent(
        intentionId: id,
        type: IntentionEventType.edited,
        occurredAt: at,
        metadata: '{"change":"content"}',
      );
      await attachedDatabase.rebuildSearchIndex();
    });
  }

  /// Hard delete (PRD §3.5 — full deletion control). The event log rows go with
  /// it; this is the one place history is allowed to disappear, at the user's
  /// explicit request.
  Future<void> deleteIntention(int id) {
    return transaction(() async {
      await (delete(
        intentionEvents,
      )..where((t) => t.intentionId.equals(id))).go();
      await (delete(intentions)..where((t) => t.id.equals(id))).go();
      await attachedDatabase.rebuildSearchIndex();
    });
  }

  Future<int> countAll() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM intentions',
      readsFrom: {intentions},
    ).getSingle();
    return row.read<int>('c');
  }

  // ------------------------------------------------------------- internals

  Future<void> _transition(
    int id, {
    required DateTime at,
    required IntentionStatus status,
    required IntentionEventType event,
    String? metadata,
  }) {
    return transaction(() async {
      final changed = await (update(intentions)..where((t) => t.id.equals(id)))
          .write(
            IntentionsCompanion(
              status: Value(status.wire),
              updatedAt: Value(at),
            ),
          );
      if (changed == 0) return;
      await _logEvent(
        intentionId: id,
        type: event,
        occurredAt: at,
        metadata: metadata,
      );
    });
  }

  Future<void> _logEvent({
    required int intentionId,
    required IntentionEventType type,
    required DateTime occurredAt,
    String? metadata,
  }) {
    return into(intentionEvents).insert(
      IntentionEventsCompanion.insert(
        intentionId: intentionId,
        type: type.wire,
        occurredAt: occurredAt,
        metadata: Value(metadata),
      ),
    );
  }
}
