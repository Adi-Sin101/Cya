import 'package:drift/drift.dart';
import 'memory_tables.dart';

@DataClassName('RoutineRow')
class Routines extends Table {
  TextColumn get id => text()();
  IntColumn get currentRevision =>
      integer().named('current_revision').withDefault(const Constant(1))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  BoolColumn get paused => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('RoutineRevisionRow')
class RoutineRevisions extends Table {
  TextColumn get id => text()();
  TextColumn get routineId => text()
      .named('routine_id')
      .references(Routines, #id, onDelete: KeyAction.cascade)();
  IntColumn get revision => integer()();
  TextColumn get title => text()();
  IntColumn get weekdays => integer().nullable()();
  IntColumn get preferredStart =>
      integer().named('preferred_start').nullable()();
  IntColumn get preferredEnd => integer().named('preferred_end').nullable()();
  TextColumn get steps => text().withDefault(const Constant('[]'))();
  TextColumn get fallback => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {routineId, revision},
  ];
  @override
  List<String> get customConstraints => [
    'CHECK (weekdays IS NULL OR weekdays BETWEEN 1 AND 127)',
    'CHECK (preferred_start IS NULL OR preferred_start BETWEEN 0 AND 1439)',
    'CHECK (preferred_end IS NULL OR (preferred_start IS NOT NULL AND preferred_end BETWEEN preferred_start AND 1439))',
  ];
}

@DataClassName('RoutineEventRow')
class RoutineEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get routineId => text()
      .named('routine_id')
      .references(Routines, #id, onDelete: KeyAction.cascade)();
  TextColumn get revisionId => text()
      .named('revision_id')
      .nullable()
      .references(RoutineRevisions, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime().named('occurred_at')();
  TextColumn get metadata => text().nullable()();
}

@DataClassName('RoutineOccurrenceRow')
class RoutineOccurrences extends Table {
  TextColumn get id => text()();
  IntColumn get changeVersion =>
      integer().named('change_version').withDefault(const Constant(1))();
  TextColumn get routineId => text()
      .named('routine_id')
      .references(Routines, #id, onDelete: KeyAction.cascade)();
  TextColumn get revisionId => text()
      .named('revision_id')
      .references(RoutineRevisions, #id, onDelete: KeyAction.cascade)();
  TextColumn get selectedDay => text().named('selected_day')();
  TextColumn get targetDay => text().named('target_day')();
  TextColumn get state => text().withDefault(const Constant('planned'))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  TextColumn get steps => text()();
  IntColumn get preferredStart =>
      integer().named('preferred_start').nullable()();
  IntColumn get preferredEnd => integer().named('preferred_end').nullable()();
  DateTimeColumn get selectedAt => dateTime().named('selected_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {routineId, selectedDay},
  ];
  @override
  List<String> get customConstraints => [
    "CHECK (state IN ('planned','completed','skipped','deferred'))",
    'CHECK (preferred_start IS NULL OR preferred_start BETWEEN 0 AND 1439)',
    'CHECK (preferred_end IS NULL OR (preferred_start IS NOT NULL AND preferred_end BETWEEN preferred_start AND 1439))',
  ];
}

@DataClassName('RoutineOccurrenceEventRow')
class RoutineOccurrenceEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get occurrenceId => text()
      .named('occurrence_id')
      .references(RoutineOccurrences, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime().named('occurred_at')();
  TextColumn get metadata => text()();
}

/// Review prose reuses immutable memory revisions/events and the semantic queue.
@DataClassName('LocalReviewRow')
class LocalReviews extends Table {
  TextColumn get id => text()();

  /// Imported copies retain their own slot and never replace this day's local note.
  TextColumn get origin => text().withDefault(const Constant('local'))();
  TextColumn get dayKey => text().named('day_key')();
  TextColumn get period => text()();
  TextColumn get memoryId => text()
      .named('memory_id')
      .unique()
      .references(Memories, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {period, dayKey, origin},
  ];
  @override
  List<String> get customConstraints => [
    "CHECK (period IN ('daily','weekly'))",
  ];
}
