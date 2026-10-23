import 'dart:convert';
import 'package:drift/drift.dart';

import '../../core/utils/local_id.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/routine.dart';
import '../db/cya_database.dart';
import 'drift_memory_repository.dart';

class RoutineRepository {
  RoutineRepository(this.db);
  final CyaDatabase db;
  Future<({RoutineRow state, RoutineRevisionRow version})> _definition(
    String id,
  ) async {
    final state = await (db.select(
      db.routines,
    )..where((r) => r.id.equals(id))).getSingle();
    final version =
        await (db.select(db.routineRevisions)..where(
              (r) =>
                  r.routineId.equals(id) &
                  r.revision.equals(state.currentRevision),
            ))
            .getSingle();
    return (state: state, version: version);
  }

  Stream<List<Routine>> watch({bool includeRemoved = false}) {
    final r = db.routines, v = db.routineRevisions;
    final query = db.select(r).join([
      innerJoin(
        v,
        v.routineId.equalsExp(r.id) & v.revision.equalsExp(r.currentRevision),
      ),
    ]);
    if (!includeRemoved) query.where(r.deletedAt.isNull());
    query.orderBy([
      OrderingTerm.asc(r.position),
      OrderingTerm.asc(r.createdAt),
    ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows) _routine(row.readTable(r), row.readTable(v)),
      ],
    );
  }

  Routine _routine(RoutineRow r, RoutineRevisionRow v) => Routine(
    id: r.id,
    revisionId: v.id,
    revision: v.revision,
    title: v.title,
    steps: routineSteps(v.steps),
    position: r.position,
    paused: r.paused,
    weekdays: v.weekdays,
    start: v.preferredStart,
    end: v.preferredEnd,
    fallback: v.fallback,
    deleted: r.deletedAt != null,
  );
  Future<String> save({
    String? id,
    required int expectedRevision,
    required String title,
    required List<String> steps,
    int? weekdays,
    int? start,
    int? end,
    String? fallback,
    required DateTime at,
  }) => db.transaction(() async {
    validateRoutine(
      title: title,
      steps: steps,
      weekdays: weekdays,
      start: start,
      end: end,
      fallback: fallback,
    );
    final old = id == null ? null : await _definition(id);
    if ((old?.version.revision ?? 0) != expectedRevision ||
        old?.state.deletedAt != null) {
      throw StateError('This routine changed. Reopen before editing.');
    }
    final key = id ?? newLocalId(), revisionId = newLocalId();
    final revision = expectedRevision + 1;
    if (old == null) {
      final position =
          (await db
                  .customSelect(
                    'SELECT COALESCE(MAX(position),-1)+1 AS next FROM routines',
                  )
                  .getSingle())
              .read<int>('next');
      await db
          .into(db.routines)
          .insert(
            RoutinesCompanion.insert(
              id: key,
              createdAt: at,
              updatedAt: at,
              position: Value(position),
            ),
          );
    } else {
      await (db.update(db.routines)..where((r) => r.id.equals(key))).write(
        RoutinesCompanion(
          currentRevision: Value(revision),
          updatedAt: Value(at),
        ),
      );
    }
    await db
        .into(db.routineRevisions)
        .insert(
          RoutineRevisionRow(
            id: revisionId,
            routineId: key,
            revision: revision,
            title: title,
            weekdays: weekdays,
            preferredStart: start,
            preferredEnd: end,
            steps: jsonEncode(steps),
            fallback: fallback,
            createdAt: at,
          ),
        );
    await db
        .into(db.routineEvents)
        .insert(
          RoutineEventsCompanion.insert(
            routineId: key,
            revisionId: Value(revisionId),
            type: old == null ? 'created' : 'edited',
            occurredAt: at,
          ),
        );
    return key;
  });
  Future<void> pause(String id, bool paused, DateTime at) =>
      db.transaction(() async {
        final old = await _definition(id);
        if (old.state.deletedAt != null) {
          throw StateError('Restore this routine before resuming.');
        }
        if (old.state.paused == paused) return;
        await (db.update(db.routines)..where((r) => r.id.equals(id))).write(
          RoutinesCompanion(paused: Value(paused), updatedAt: Value(at)),
        );
        await db
            .into(db.routineEvents)
            .insert(
              RoutineEventsCompanion.insert(
                routineId: id,
                revisionId: Value(old.version.id),
                type: paused ? 'paused' : 'resumed',
                occurredAt: at,
              ),
            );
      });
  Future<void> remove(String id, DateTime at, {bool restore = false}) =>
      db.transaction(() async {
        final old = await _definition(id);
        await (db.update(db.routines)..where((r) => r.id.equals(id))).write(
          RoutinesCompanion(
            paused: const Value(true),
            deletedAt: Value(restore ? null : at),
            updatedAt: Value(at),
          ),
        );
        await db
            .into(db.routineEvents)
            .insert(
              RoutineEventsCompanion.insert(
                routineId: id,
                revisionId: Value(old.version.id),
                type: restore ? 'restored' : 'removed',
                occurredAt: at,
              ),
            );
      });
  Future<void> reorder(
    List<String> ids,
    DateTime at,
  ) => db.transaction(() async {
    final rows = await (db.select(
      db.routines,
    )..where((r) => r.deletedAt.isNull())).get();
    if (ids.length != ids.toSet().length ||
        ids.length != rows.length ||
        !ids.toSet().containsAll(rows.map((r) => r.id))) {
      throw StateError('The routine list changed. Reopen before reordering.');
    }
    final byId = {for (final r in rows) r.id: r};
    for (var index = 0; index < ids.length; index++) {
      final old = byId[ids[index]]!;
      if (old.position == index) continue;
      await (db.update(db.routines)..where((r) => r.id.equals(old.id))).write(
        RoutinesCompanion(position: Value(index), updatedAt: Value(at)),
      );
      await db
          .into(db.routineEvents)
          .insert(
            RoutineEventsCompanion.insert(
              routineId: old.id,
              type: 'reordered',
              occurredAt: at,
              metadata: Value(jsonEncode({'from': old.position, 'to': index})),
            ),
          );
    }
  });
  Future<String> select(
    String id,
    DateTime day,
    DateTime at,
  ) => db.transaction(() async {
    final definition = await _definition(id), key = localDayKey(day);
    if (definition.state.paused || definition.state.deletedAt != null) {
      throw StateError('Resume the routine before selecting it.');
    }
    final previous =
        await (db.select(db.routineOccurrences)..where(
              (o) =>
                  o.routineId.equals(id) &
                  (o.selectedDay.equals(key) |
                      (o.targetDay.equals(key) &
                          o.state.isIn(['planned', 'deferred']))),
            ))
            .get();
    if (previous.isNotEmpty) return previous.first.id;
    final last =
        (await db
                .customSelect(
                  'SELECT COALESCE(MAX(position),-1)+1 AS next FROM routine_occurrences WHERE target_day=?',
                  variables: [Variable.withString(key)],
                )
                .getSingle())
            .read<int>('next');
    final v = definition.version, occurrenceId = newLocalId();
    final row = RoutineOccurrenceRow(
      id: occurrenceId,
      changeVersion: 1,
      routineId: id,
      revisionId: v.id,
      selectedDay: key,
      targetDay: key,
      state: 'planned',
      position: last,
      steps: v.steps,
      preferredStart: v.preferredStart,
      preferredEnd: v.preferredEnd,
      selectedAt: at,
      updatedAt: at,
    );
    await db.into(db.routineOccurrences).insert(row);
    await db
        .into(db.routineOccurrenceEvents)
        .insert(
          RoutineOccurrenceEventsCompanion.insert(
            occurrenceId: occurrenceId,
            type: 'selected',
            occurredAt: at,
            metadata: jsonEncode({
              'before': null,
              'after': row.toJson(),
              'usualWeekday': _routine(definition.state, v).eligible(day),
            }),
          ),
        );
    return occurrenceId;
  });
  Stream<List<RoutineOccurrence>> occurrences(
    DateTime day, {
    bool earlierOpen = false,
  }) {
    final key = localDayKey(day);
    return db
        .customSelect(
          '''SELECT o.*,v.title,v.fallback FROM routine_occurrences o
      JOIN routine_revisions v ON v.id=o.revision_id WHERE ${earlierOpen ? "o.target_day<? AND o.state IN ('planned','deferred')" : 'o.target_day=?'}
      ORDER BY o.target_day,o.position,o.selected_at''',
          variables: [Variable.withString(key)],
          readsFrom: {db.routineOccurrences, db.routineRevisions},
        )
        .watch()
        .map((rows) => rows.map(_occurrence).toList());
  }

  Future<RoutineOccurrence?> occurrenceById(String id) async {
    final row = await db
        .customSelect(
          '''SELECT o.*,v.title,v.fallback FROM routine_occurrences o
      JOIN routine_revisions v ON v.id=o.revision_id WHERE o.id=?''',
          variables: [Variable.withString(id)],
          readsFrom: {db.routineOccurrences, db.routineRevisions},
        )
        .getSingleOrNull();
    return row == null ? null : _occurrence(row);
  }

  RoutineOccurrence _occurrence(QueryRow r) => RoutineOccurrence(
    id: r.read('id'),
    routineId: r.read('routine_id'),
    revisionId: r.read('revision_id'),
    title: r.read('title'),
    version: r.read('change_version'),
    state: r.read('state'),
    selectedDay: r.read('selected_day'),
    targetDay: r.read('target_day'),
    steps: routineSteps(r.read('steps')),
    position: r.read('position'),
    start: r.readNullable('preferred_start'),
    end: r.readNullable('preferred_end'),
    fallback: r.readNullable('fallback'),
  );

  Future<void> change(
    String id,
    DateTime at, {
    required int expectedVersion,
    String? state,
    DateTime? day,
    List<String>? steps,
    ({int? start, int? end})? window,
    int? position,
  }) => db.transaction(() async {
    final old = await (db.select(
      db.routineOccurrences,
    )..where((o) => o.id.equals(id))).getSingle();
    if (old.changeVersion != expectedVersion) {
      throw StateError('This plan changed. Reopen before changing it.');
    }
    final nextState = state ?? old.state;
    if (!const {
      'planned',
      'completed',
      'skipped',
      'deferred',
    }.contains(nextState)) {
      throw ArgumentError('Choose a recorded outcome.');
    }
    final effectiveSteps = steps ?? routineSteps(old.steps),
        start = window == null ? old.preferredStart : window.start,
        end = window == null ? old.preferredEnd : window.end;
    validateRoutine(
      title: 'Occurrence',
      steps: effectiveSteps,
      start: start,
      end: end,
    );
    final next = old.copyWith(
      changeVersion: old.changeVersion + 1,
      state: nextState,
      targetDay: day == null ? old.targetDay : localDayKey(day),
      steps: jsonEncode(effectiveSteps),
      preferredStart: Value(start),
      preferredEnd: Value(end),
      position: position ?? old.position,
      updatedAt: at,
    );
    if (next.state == old.state &&
        next.targetDay == old.targetDay &&
        next.steps == old.steps &&
        next.preferredStart == old.preferredStart &&
        next.preferredEnd == old.preferredEnd &&
        next.position == old.position) {
      return;
    }
    await db.update(db.routineOccurrences).replace(next);
    final type = state != null
        ? (state == 'planned' ? 'replanned' : state)
        : steps != null
        ? 'steps_changed'
        : position != null
        ? 'reordered'
        : 'replanned';
    await db
        .into(db.routineOccurrenceEvents)
        .insert(
          RoutineOccurrenceEventsCompanion.insert(
            occurrenceId: id,
            type: type,
            occurredAt: at,
            metadata: jsonEncode({
              'before': old.toJson(),
              'after': next.toJson(),
            }),
          ),
        );
  });
  Stream<List<RoutineOccurrenceEventRow>> occurrenceHistory(String id) =>
      (db.select(db.routineOccurrenceEvents)
            ..where((e) => e.occurrenceId.equals(id))
            ..orderBy([(e) => OrderingTerm.desc(e.id)]))
          .watch();

  Future<void> pauseAfterDisruption(
    String id,
    DateTime day,
    DateTime at, {
    required int expectedVersion,
  }) => db.transaction(() async {
    final occurrence = await (db.select(
      db.routineOccurrences,
    )..where((o) => o.id.equals(id))).getSingle();
    await change(
      id,
      at,
      expectedVersion: expectedVersion,
      state: 'deferred',
      day: day,
    );
    await pause(occurrence.routineId, true, at);
  });

  Future<void> moveOccurrence(
    String id,
    int direction,
    DateTime at, {
    required int expectedVersion,
  }) => db.transaction(() async {
    if (direction != 1 && direction != -1) {
      throw ArgumentError('Choose a neighboring position.');
    }
    final old = await (db.select(
      db.routineOccurrences,
    )..where((o) => o.id.equals(id))).getSingle();
    if (old.changeVersion != expectedVersion) {
      throw StateError('The plan changed. Reopen before reordering.');
    }
    final rows =
        await (db.select(db.routineOccurrences)
              ..where((o) => o.targetDay.equals(old.targetDay))
              ..orderBy([
                (o) => OrderingTerm.asc(o.position),
                (o) => OrderingTerm.asc(o.selectedAt),
                (o) => OrderingTerm.asc(o.id),
              ]))
            .get();
    final index = rows.indexWhere((o) => o.id == id), other = index + direction;
    if (other < 0 || other >= rows.length) return;
    final moved = rows.removeAt(index);
    rows.insert(other, moved);
    for (var i = 0; i < rows.length; i++) {
      final previous = rows[i];
      if (previous.position == i) continue;
      final next = previous.copyWith(
        position: i,
        changeVersion: previous.changeVersion + 1,
        updatedAt: at,
      );
      await db.update(db.routineOccurrences).replace(next);
      await db
          .into(db.routineOccurrenceEvents)
          .insert(
            RoutineOccurrenceEventsCompanion.insert(
              occurrenceId: previous.id,
              type: 'reordered',
              occurredAt: at,
              metadata: jsonEncode({
                'before': previous.toJson(),
                'after': next.toJson(),
              }),
            ),
          );
    }
  });

  ({DateTime start, DateTime end, String key}) reviewPeriod(
    DateTime day,
    String period,
  ) {
    if (!const {'daily', 'weekly'}.contains(period)) {
      throw ArgumentError('Choose a daily or weekly review.');
    }
    final date = DateTime(day.year, day.month, day.day);
    final start = period == 'daily'
        ? date
        : DateTime(date.year, date.month, date.day - (date.weekday - 1));
    final end = DateTime(
      start.year,
      start.month,
      start.day + (period == 'daily' ? 1 : 7),
    );
    return (start: start, end: end, key: localDayKey(start));
  }

  Future<LocalReviewFacts> facts(DateTime day, String period) async {
    final range = reviewPeriod(day, period);
    final events =
        await (db.select(db.routineOccurrenceEvents)
              ..where(
                (e) =>
                    e.occurredAt.isBiggerOrEqualValue(range.start) &
                    e.occurredAt.isSmallerThanValue(range.end),
              )
              ..orderBy([
                (e) => OrderingTerm.asc(e.occurredAt),
                (e) => OrderingTerm.asc(e.id),
              ]))
            .get();
    final last = <String, String>{},
        selected = <String>{},
        deferrals = <String, int>{},
        versionIds = <String, String>{};
    for (final event in events) {
      final after = (jsonDecode(event.metadata) as Map)['after'] as Map;
      last[event.occurrenceId] = after['state'] as String;
      if (event.type == 'selected') selected.add(event.occurrenceId);
      if (event.type == 'deferred') {
        final routine = after['routineId'] as String;
        deferrals.update(routine, (n) => n + 1, ifAbsent: () => 1);
        versionIds[routine] = after['revisionId'] as String;
      }
    }
    final states = {
      for (final state in ['planned', 'completed', 'skipped', 'deferred'])
        state: 0,
    };
    for (final state in last.values) {
      states.update(state, (n) => n + 1);
    }
    final taskEvents =
        await (db.select(db.intentionEvents)..where(
              (e) =>
                  e.occurredAt.isBiggerOrEqualValue(range.start) &
                  e.occurredAt.isSmallerThanValue(range.end),
            ))
            .get();
    final evidence = <String>[];
    for (final entry in deferrals.entries.where((e) => e.value >= 3)) {
      final v = await (db.select(
        db.routineRevisions,
      )..where((r) => r.id.equals(versionIds[entry.key]!))).getSingle();
      evidence.add(
        '${entry.value} explicit deferrals recorded for “${v.title}” in this period. You can review its preferred window or choose your own lighter steps.',
      );
    }
    return LocalReviewFacts(
      routineStates: states,
      routinesSelected: selected.length,
      promisesCompleted: taskEvents
          .where((e) => e.type == 'resolved')
          .map((e) => e.intentionId)
          .toSet()
          .length,
      promisesDeferred: taskEvents
          .where((e) => e.type == 'snoozed')
          .map((e) => e.intentionId)
          .toSet()
          .length,
      adjustmentEvidence: evidence,
    );
  }

  Future<String> saveReview(
    DateTime day,
    String period,
    String text,
    DateTime at, {
    required int expectedRevision,
  }) => db.transaction(() async {
    if (text.trim().isEmpty || text.length > 1000) {
      throw ArgumentError(
        'A note is optional; use up to1,000 characters when saving one.',
      );
    }
    final range = reviewPeriod(day, period);
    final old =
        await (db.select(db.localReviews)..where(
              (r) =>
                  r.dayKey.equals(range.key) &
                  r.period.equals(period) &
                  r.origin.equals('local'),
            ))
            .getSingleOrNull();
    final memories = DriftMemoryRepository(db);
    if (old == null) {
      if (expectedRevision != 0) {
        throw StateError('This review changed. Reopen before editing.');
      }
      final memoryId = await memories.captureText(text, at);
      await db
          .into(db.localReviews)
          .insert(
            LocalReviewRow(
              id: newLocalId(),
              origin: 'local',
              dayKey: range.key,
              period: period,
              memoryId: memoryId,
              createdAt: at,
            ),
          );
      return memoryId;
    }
    await memories.edit(
      old.memoryId,
      text,
      at,
      expectedRevision: expectedRevision,
    );
    return old.memoryId;
  });
  Future<Memory?> reviewNote(DateTime day, String period) async {
    final range = reviewPeriod(day, period);
    final row =
        await (db.select(db.localReviews)..where(
              (r) =>
                  r.dayKey.equals(range.key) &
                  r.period.equals(period) &
                  r.origin.equals('local'),
            ))
            .getSingleOrNull();
    return row == null
        ? null
        : (await DriftMemoryRepository(db).history(row.memoryId).first).first;
  }
}
