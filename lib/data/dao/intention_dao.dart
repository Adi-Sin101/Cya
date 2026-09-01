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

  /// Every kept promise, oldest first — the Memory Garden's raw material
  /// (PRD §6.6). Only `resolved` rows, so the stream stays proportional to what
  /// the garden actually draws rather than to the whole log.
  Stream<List<IntentionEvent>> watchResolutions() {
    final query = select(intentionEvents)
      ..where((t) => t.type.equals(IntentionEventType.resolved.wire))
      ..orderBy([(t) => OrderingTerm(expression: t.occurredAt)]);
    return query.watch().map((rows) => rows.toEntities());
  }

  /// The two flavour counts the achievement badges need (PRD §8.2 *Reader* and
  /// *Communicator*), as one aggregate rather than a scan in Dart.
  ///
  /// Counted over current-state rows: a promise resolved, reopened and resolved
  /// again is one kept promise, not two.
  Stream<({int links, int conversations})> watchResolvedBreakdown() {
    final apps = _messagingApps.map((app) => "'$app'").join(', ');
    return customSelect(
      'SELECT '
      'SUM(CASE WHEN deep_link IS NOT NULL THEN 1 ELSE 0 END) AS links, '
      'SUM(CASE WHEN LOWER(source_app) IN ($apps) THEN 1 ELSE 0 END) '
      'AS conversations '
      "FROM intentions WHERE status = 'resolved'",
      readsFrom: {intentions},
    ).watch().map((rows) {
      final row = rows.first;
      return (
        links: row.read<int?>('links') ?? 0,
        conversations: row.read<int?>('conversations') ?? 0,
      );
    });
  }

  /// Apps whose promises count as conversations. Lower-case; matched exactly.
  static const List<String> _messagingApps = <String>[
    'messenger',
    'whatsapp',
    'telegram',
    'signal',
    'discord',
    'slack',
    'messages',
    'gmail',
    'instagram',
  ];

  // ----------------------------------------------------------- mutations

  /// The capture write: one row + one `captured` event, nothing else
  /// (PRD §3.2). Mirrors what the native writer does natively.
  Future<int> capture(NewIntention capture) {
    return transaction(() async {
      final id = await into(intentions).insert(
        IntentionsCompanion.insert(
          sourceApp: capture.sourceApp,
          sourcePackage: Value(capture.sourcePackage),
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

  /// Promises enrichment has not looked at yet (PRD §5.5).
  ///
  /// "Not looked at" is `category IS NULL AND extracted_deadline IS NULL` —
  /// a promise the user categorised by hand is excluded for free, which is
  /// what stops a startup pass from ever second-guessing them.
  ///
  /// Bounded, because this runs on every launch and an unbounded scan of a
  /// years-old table to re-check rows that matched nothing the first time is
  /// exactly the kind of waste PRD §9.4 rules out. Newest first: a promise
  /// captured minutes ago is the one whose reminder is still worth moving.
  Future<List<Intention>> needingEnrichment({int limit = 60}) async {
    final rows =
        await (select(intentions)
              ..where((t) => t.category.isNull() & t.extractedDeadline.isNull())
              ..orderBy(<OrderClauseGenerator<$IntentionsTable>>[
                (t) => OrderingTerm.desc(t.id),
              ])
              ..limit(limit))
            .get();
    return <Intention>[for (final row in rows) row.toEntity()];
  }

  /// Records what on-device enrichment found (PRD §5.5).
  ///
  /// [reminderAt] is only passed when enrichment has earned the right to move
  /// the alarm — the caller decides that, not this DAO. The event names the
  /// change as `enrichment` so the log can always tell an automatic edit from
  /// one the user made (PRD §7.1).
  Future<void> recordExtractedDeadline(
    int id, {
    required DateTime deadline,
    required DateTime? reminderAt,
    required DateTime at,
  }) {
    return transaction(() async {
      await (update(intentions)..where((t) => t.id.equals(id))).write(
        IntentionsCompanion(
          extractedDeadline: Value(deadline),
          reminderAt: reminderAt == null
              ? const Value.absent()
              : Value(reminderAt),
          updatedAt: Value(at),
        ),
      );
      await _logEvent(
        intentionId: id,
        type: IntentionEventType.edited,
        occurredAt: at,
        metadata:
            '{"change":"enrichment","deadline":'
            '${deadline.millisecondsSinceEpoch ~/ 1000}'
            '${reminderAt == null ? '' : ',"rescheduled":true'}}',
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

  // ------------------------------------------------- retirement (ADR-014)

  /// Archives every pending promise untouched since [cutoff], returning their
  /// ids so the caller can cancel their alarms.
  ///
  /// One transaction for the whole sweep: a half-retired batch would leave
  /// alarms armed for rows the UI no longer shows. Each row still gets its own
  /// `archived` event carrying [reason] — the log's job is to explain *why* a
  /// promise ended, and "the calendar did it" is a different answer from "the
  /// user did it" (PRD §7.1).
  Future<List<int>> retireStale({
    required DateTime cutoff,
    required DateTime at,
    required String reason,
  }) {
    return transaction(() async {
      final stale =
          await (select(intentions)
                ..where(
                  (t) =>
                      t.status.isIn(<String>[
                        IntentionStatus.open.wire,
                        IntentionStatus.snoozed.wire,
                      ]) &
                      t.updatedAt.isSmallerOrEqualValue(cutoff),
                ))
              .get();
      if (stale.isEmpty) return const <int>[];

      for (final row in stale) {
        await (update(intentions)..where((t) => t.id.equals(row.id))).write(
          IntentionsCompanion(
            status: Value(IntentionStatus.archived.wire),
            updatedAt: Value(at),
          ),
        );
        await _logEvent(
          intentionId: row.id,
          type: IntentionEventType.archived,
          occurredAt: at,
          metadata: '{"reason":"$reason"}',
        );
      }
      return <int>[for (final row in stale) row.id];
    });
  }

  /// Promises retired automatically since [since], newest first.
  ///
  /// Read from the event log rather than from a flag on the row, because the
  /// log is the only place that remembers *why* something was archived — and
  /// the digest's offer to bring one back depends on that distinction.
  Stream<List<Intention>> watchRetiredSince(DateTime since, String reason) {
    return customSelect(
      'SELECT i.* FROM intentions i '
      'JOIN intention_events e ON e.intention_id = i.id '
      "WHERE i.status = 'archived' AND e.type = 'archived' "
      'AND e.occurred_at >= ?1 '
      "AND e.metadata LIKE '%\"reason\":\"' || ?2 || '\"%' "
      'GROUP BY i.id ORDER BY e.occurred_at DESC',
      variables: <Variable<Object>>[
        Variable<int>(since.millisecondsSinceEpoch ~/ 1000),
        Variable<String>(reason),
      ],
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
        intentions,
        intentionEvents,
      },
    ).watch().map(
      (rows) => <Intention>[
        for (final row in rows) intentions.map(row.data).toEntity(),
      ],
    );
  }

  // ------------------------------------------------ export & erase (§9.3)

  /// Every intention, archived ones included, oldest first.
  ///
  /// Export means *everything*: filtering here would quietly make the file a
  /// summary, and a data export the vendor has curated is not a data export.
  Future<List<Intention>> allForExport() async {
    final rows =
        await (select(intentions)
              ..orderBy(<OrderClauseGenerator<$IntentionsTable>>[
                (t) => OrderingTerm(expression: t.id),
              ]))
            .get();
    return <Intention>[for (final row in rows) row.toEntity()];
  }

  /// The whole append-only log, oldest first.
  Future<List<IntentionEvent>> allEventsForExport() async {
    final rows =
        await (select(intentionEvents)
              ..orderBy(<OrderClauseGenerator<$IntentionEventsTable>>[
                (t) => OrderingTerm(expression: t.id),
              ]))
            .get();
    return rows.toEntities();
  }

  /// Erases every promise and every event (PRD §9.3).
  ///
  /// Events go first: they carry a foreign key onto intentions, and deleting
  /// the parents first would either fail or cascade depending on a pragma —
  /// neither is something to leave to chance in the one operation that must
  /// not half-succeed. The FTS index is rebuilt rather than dropped, so a
  /// later capture is not searched against ghosts.
  Future<void> eraseEverything() async {
    await transaction(() async {
      await delete(intentionEvents).go();
      await delete(intentions).go();
    });
    await attachedDatabase.rebuildSearchIndex();
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
