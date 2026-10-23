import 'package:drift/drift.dart';
import 'tables.dart';

@DataClassName('MemoryRow')
class Memories extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text().withDefault(const Constant('text'))();
  TextColumn get source => text().withDefault(const Constant('Cya!'))();
  DateTimeColumn get capturedAt => dateTime().named('captured_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get archivedAt => dateTime().named('archived_at').nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MemoryRevisionRow')
class MemoryRevisions extends Table {
  TextColumn get id => text()();
  TextColumn get memoryId => text()
      .named('memory_id')
      .references(Memories, #id, onDelete: KeyAction.cascade)();
  IntColumn get revision => integer()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {memoryId, revision},
  ];
}

@DataClassName('MemoryEventRow')
class MemoryEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get memoryId => text()
      .named('memory_id')
      .references(Memories, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime().named('occurred_at')();
  TextColumn get revisionId => text()
      .named('revision_id')
      .nullable()
      .references(MemoryRevisions, #id, onDelete: KeyAction.cascade)();
  TextColumn get metadata => text().nullable()();
}

/// Pending work is durable before save acknowledgement; no model runs in a DAO.
@DataClassName('MemoryJobRow')
class MemoryJobs extends Table {
  TextColumn get revisionId => text()
      .named('revision_id')
      .references(MemoryRevisions, #id, onDelete: KeyAction.cascade)();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get retryAt => dateTime().named('retry_at').nullable()();
  TextColumn get lastError => text().named('last_error').nullable()();
  IntColumn get nextSegment =>
      integer().named('next_segment').withDefault(const Constant(0))();
  TextColumn get modelVersion => text().named('model_version').nullable()();
  @override
  Set<Column<Object>> get primaryKey => {revisionId};
}

@DataClassName('MemoryVectorRow')
class MemoryVectors extends Table {
  TextColumn get revisionId => text()
      .named('revision_id')
      .references(MemoryRevisions, #id, onDelete: KeyAction.cascade)();
  IntColumn get segment => integer()();
  TextColumn get modelVersion => text().named('model_version')();
  IntColumn get dimensions => integer()();
  BlobColumn get vector => blob()();
  @override
  Set<Column<Object>> get primaryKey => {revisionId, segment};
}

@DataClassName('MemoryLinkRow')
class MemoryLinks extends Table {
  TextColumn get id => text()();
  TextColumn get fromRevision => text()
      .named('from_revision')
      .references(MemoryRevisions, #id, onDelete: KeyAction.cascade)();
  TextColumn get toRevision => text()
      .named('to_revision')
      .references(MemoryRevisions, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => text()();
  TextColumn get provenance => text()();
  TextColumn get state => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {fromRevision, toRevision, kind},
  ];
}

@DataClassName('MemoryAttachmentRow')
class MemoryAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get memoryId => text()
      .named('memory_id')
      .references(Memories, #id, onDelete: KeyAction.cascade)();
  TextColumn get fileName => text().named('file_name').unique()();
  TextColumn get sha256 => text()();
  IntColumn get byteLength => integer().named('byte_length')();
  IntColumn get durationMillis => integer().named('duration_millis')();
  DateTimeColumn get capturedAt => dateTime().named('captured_at')();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {memoryId},
  ];
}

/// No FK to the removed source: cleanup survives process death after deletion.
@DataClassName('AttachmentCleanupRow')
class AttachmentCleanup extends Table {
  TextColumn get fileName => text().named('file_name')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  @override
  Set<Column<Object>> get primaryKey => {fileName};
}

@DataClassName('FocusSessionRow')
class FocusSessions extends Table {
  TextColumn get id => text()();
  TextColumn get priority => text()();
  DateTimeColumn get startedAt => dateTime().named('started_at')();
  DateTimeColumn get endedAt => dateTime().named('ended_at').nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('FocusEventRow')
class FocusEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()
      .named('session_id')
      .references(FocusSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime().named('occurred_at')();
}

@DataClassName('MemoryCollectionRow')
class MemoryCollections extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get kind => text()();
  TextColumn get parentId => text()
      .named('parent_id')
      .nullable()
      .references(MemoryCollections, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<String> get customConstraints => ["CHECK (kind IN ('topic','project'))"];
}

@DataClassName('CollectionEventRow')
class CollectionEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get collectionId => text()
      .named('collection_id')
      .references(MemoryCollections, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime().named('occurred_at')();
  TextColumn get metadata => text()();
}

@DataClassName('MemoryAssignmentRow')
class MemoryAssignments extends Table {
  TextColumn get id => text()();
  TextColumn get revisionId => text()
      .named('revision_id')
      .references(MemoryRevisions, #id, onDelete: KeyAction.cascade)();
  IntColumn get intentionId => integer()
      .named('intention_id')
      .nullable()
      .references(Intentions, #id, onDelete: KeyAction.cascade)();
  TextColumn get collectionId => text()
      .named('collection_id')
      .nullable()
      .references(MemoryCollections, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => text()();
  TextColumn get context => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {revisionId, intentionId},
    {revisionId, collectionId},
  ];
  @override
  List<String> get customConstraints => [
    "CHECK ((intention_id IS NOT NULL AND collection_id IS NULL AND kind='intention') OR (intention_id IS NULL AND collection_id IS NOT NULL AND kind='collection'))",
  ];
}
