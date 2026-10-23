import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/utils/local_id.dart';
import '../../domain/entities/routine.dart';
import '../db/cya_database.dart';

/// Validates immutable routine/occurrence history before any import writes.
class RoutineBackup {
  RoutineBackup._(
    this.routines,
    this.revisions,
    this.events,
    this.occurrences,
    this.occurrenceEvents,
    this.reviews,
  );
  final List<RoutineRow> routines;
  final List<RoutineRevisionRow> revisions;
  final List<RoutineEventRow> events;
  final List<RoutineOccurrenceRow> occurrences;
  final List<RoutineOccurrenceEventRow> occurrenceEvents;
  final List<LocalReviewRow> reviews;
  static RoutineBackup parse(
    Map<String, dynamic> data,
    Map<String, String> memoryKinds,
  ) {
    void require(bool value) {
      if (!value) {
        throw const FormatException(
          'Routine or review history is inconsistent.',
        );
      }
    }

    List<T> rows<T>(String key, T Function(Map<String, dynamic>) decode) {
      final values = data[key] ?? const [];
      require(
        values is List &&
            values.length <= 100000 &&
            ((data['counts'] as Map)[key] ?? 0) == values.length,
      );
      require((data['formatVersion'] as int) >= 7 || (values as List).isEmpty);
      return [
        for (final value in values as List)
          decode(Map<String, dynamic>.from(value as Map)),
      ];
    }

    final routines = rows('routines', RoutineRow.fromJson),
        revisions = rows('routineRevisions', RoutineRevisionRow.fromJson),
        events = rows('routineEvents', RoutineEventRow.fromJson),
        occurrences = rows('routineOccurrences', RoutineOccurrenceRow.fromJson),
        occurrenceEvents = rows(
          'routineOccurrenceEvents',
          RoutineOccurrenceEventRow.fromJson,
        ),
        reviews = rows('localReviews', LocalReviewRow.fromJson);
    Set<T> unique<T>(Iterable<T> values) {
      final list = values.toList(), set = values.toSet();
      require(list.length == set.length);
      return set;
    }

    final routineIds = unique(routines.map((r) => r.id)),
        revisionIds = unique(revisions.map((r) => r.id)),
        occurrenceIds = unique(occurrences.map((o) => o.id));
    unique(events.map((e) => e.id));
    unique(occurrenceEvents.map((e) => e.id));
    unique(reviews.map((r) => r.id));
    unique(reviews.map((r) => r.memoryId));
    unique(reviews.map((r) => '${r.period}:${r.dayKey}:${r.origin}'));
    unique(occurrences.map((o) => '${o.routineId}:${o.selectedDay}'));
    final versions = <String, List<RoutineRevisionRow>>{},
        routineEvents = <String, List<RoutineEventRow>>{},
        history = <String, List<RoutineOccurrenceEventRow>>{};
    final byRevision = {for (final r in revisions) r.id: r};
    for (final r in revisions) {
      require(routineIds.contains(r.routineId) && r.revision >= 1);
      validateRoutine(
        title: r.title,
        steps: routineSteps(r.steps),
        weekdays: r.weekdays,
        start: r.preferredStart,
        end: r.preferredEnd,
        fallback: r.fallback,
      );
      versions.putIfAbsent(r.routineId, () => []).add(r);
    }
    for (final e in events) {
      require(
        routineIds.contains(e.routineId) &&
            (e.revisionId == null ||
                (revisionIds.contains(e.revisionId) &&
                    byRevision[e.revisionId]?.routineId == e.routineId)) &&
            const {
              'created',
              'edited',
              'paused',
              'resumed',
              'reordered',
              'removed',
              'restored',
            }.contains(e.type),
      );
      routineEvents.putIfAbsent(e.routineId, () => []).add(e);
    }
    for (final r in routines) {
      final versionsFor = versions[r.id] ?? [];
      versionsFor.sort((a, b) => a.revision.compareTo(b.revision));
      require(
        r.id.isNotEmpty &&
            r.position >= 0 &&
            versionsFor.isNotEmpty &&
            versionsFor.length == r.currentRevision,
      );
      for (var i = 0; i < versionsFor.length; i++) {
        require(versionsFor[i].revision == i + 1);
      }
      final records = routineEvents[r.id] ?? [];
      records.sort((a, b) => a.id.compareTo(b.id));
      require(records.where((e) => e.type == 'created').length == 1);
      for (final version in versionsFor) {
        require(
          records.any(
            (e) =>
                e.revisionId == version.id &&
                e.type == (version.revision == 1 ? 'created' : 'edited'),
          ),
        );
      }
      var paused = false, removed = false;
      for (final e in records) {
        if (e.type == 'paused') paused = true;
        if (e.type == 'resumed') paused = false;
        if (e.type == 'removed') {
          removed = true;
          paused = true;
        }
        if (e.type == 'restored') {
          removed = false;
          paused = true;
        }
      }
      require(r.paused == paused && (r.deletedAt != null) == removed);
    }
    for (final e in occurrenceEvents) {
      require(
        occurrenceIds.contains(e.occurrenceId) &&
            const {
              'selected',
              'completed',
              'skipped',
              'deferred',
              'replanned',
              'steps_changed',
              'reordered',
            }.contains(e.type),
      );
      history.putIfAbsent(e.occurrenceId, () => []).add(e);
    }
    String comparable(RoutineOccurrenceRow row) {
      final json = row.toJson();
      for (final key in ['selectedAt', 'updatedAt']) {
        json[key] = (json[key] as int) ~/ 1000;
      }
      return jsonEncode(json);
    }

    for (final o in occurrences) {
      require(
        routineIds.contains(o.routineId) &&
            byRevision[o.revisionId]?.routineId == o.routineId &&
            o.position >= 0,
      );
      parseLocalDay(o.selectedDay);
      parseLocalDay(o.targetDay);
      validateRoutine(
        title: 'Occurrence',
        steps: routineSteps(o.steps),
        start: o.preferredStart,
        end: o.preferredEnd,
      );
      require(
        const {'planned', 'completed', 'skipped', 'deferred'}.contains(o.state),
      );
      final records = history[o.id] ?? [];
      records.sort((a, b) => a.id.compareTo(b.id));
      require(records.length == o.changeVersion && records.isNotEmpty);
      RoutineOccurrenceRow? previous;
      for (var i = 0; i < records.length; i++) {
        final record = records[i],
            metadata = jsonDecode(record.metadata) as Map;
        final after = RoutineOccurrenceRow.fromJson(
          Map<String, dynamic>.from(metadata['after'] as Map),
        );
        require(
          after.id == o.id &&
              after.routineId == o.routineId &&
              after.revisionId == o.revisionId &&
              after.selectedDay == o.selectedDay &&
              after.changeVersion == i + 1,
        );
        parseLocalDay(after.targetDay);
        validateRoutine(
          title: 'Occurrence',
          steps: routineSteps(after.steps),
          start: after.preferredStart,
          end: after.preferredEnd,
        );
        require(
          after.position >= 0 &&
              const {
                'planned',
                'completed',
                'skipped',
                'deferred',
              }.contains(after.state),
        );
        if (i == 0) {
          require(
            record.type == 'selected' &&
                metadata['before'] == null &&
                after.state == 'planned',
          );
        } else {
          final before = RoutineOccurrenceRow.fromJson(
            Map<String, dynamic>.from(metadata['before'] as Map),
          );
          require(comparable(before) == comparable(previous!));
          if (after.state != before.state) {
            require(
              record.type ==
                  (after.state == 'planned' ? 'replanned' : after.state),
            );
          }
        }
        if (const {'completed', 'skipped', 'deferred'}.contains(record.type)) {
          require(after.state == record.type);
        }
        previous = after;
      }
      require(comparable(previous!) == comparable(o));
    }
    for (final r in reviews) {
      final day = parseLocalDay(r.dayKey);
      require(
        const {'daily', 'weekly'}.contains(r.period) &&
            (r.origin == 'local' ||
                RegExp(r'^import:[a-f0-9-]{36}$').hasMatch(r.origin)) &&
            (r.period != 'weekly' || day.weekday == DateTime.monday) &&
            memoryKinds[r.memoryId] == 'text',
      );
    }
    events.sort((a, b) => a.id.compareTo(b.id));
    occurrenceEvents.sort((a, b) => a.id.compareTo(b.id));
    return RoutineBackup._(
      routines,
      revisions,
      events,
      occurrences,
      occurrenceEvents,
      reviews,
    );
  }

  /// Called inside the encompassing backup source/event/job transaction.
  Future<void> append(CyaDatabase db, Map<String, String> memoryIds) async {
    final routineIds = {for (final r in routines) r.id: newLocalId()},
        revisionIds = {for (final r in revisions) r.id: newLocalId()},
        occurrenceIds = {for (final o in occurrences) o.id: newLocalId()};
    for (final r in routines) {
      await db
          .into(db.routines)
          .insert(r.copyWith(id: routineIds[r.id]!).toCompanion(true));
    }
    for (final r in revisions) {
      await db
          .into(db.routineRevisions)
          .insert(
            r
                .copyWith(
                  id: revisionIds[r.id]!,
                  routineId: routineIds[r.routineId]!,
                )
                .toCompanion(true),
          );
    }
    for (final e in events) {
      await db
          .into(db.routineEvents)
          .insert(
            e
                .toCompanion(true)
                .copyWith(
                  id: const Value.absent(),
                  routineId: Value(routineIds[e.routineId]!),
                  revisionId: Value(
                    e.revisionId == null ? null : revisionIds[e.revisionId],
                  ),
                ),
          );
    }
    for (final o in occurrences) {
      await db
          .into(db.routineOccurrences)
          .insert(
            o
                .copyWith(
                  id: occurrenceIds[o.id]!,
                  routineId: routineIds[o.routineId]!,
                  revisionId: revisionIds[o.revisionId]!,
                )
                .toCompanion(true),
          );
    }
    for (final e in occurrenceEvents) {
      final data = jsonDecode(e.metadata) as Map<String, dynamic>;
      for (final side in ['before', 'after']) {
        final row = data[side] as Map?;
        if (row != null) {
          row['id'] = occurrenceIds[row['id']];
          row['routineId'] = routineIds[row['routineId']];
          row['revisionId'] = revisionIds[row['revisionId']];
        }
      }
      await db
          .into(db.routineOccurrenceEvents)
          .insert(
            e
                .toCompanion(true)
                .copyWith(
                  id: const Value.absent(),
                  occurrenceId: Value(occurrenceIds[e.occurrenceId]!),
                  metadata: Value(jsonEncode(data)),
                ),
          );
    }
    for (final r in reviews) {
      await db
          .into(db.localReviews)
          .insert(
            r
                .copyWith(
                  id: newLocalId(),
                  origin: 'import:${newLocalId()}',
                  memoryId: memoryIds[r.memoryId]!,
                )
                .toCompanion(true),
          );
    }
  }
}
