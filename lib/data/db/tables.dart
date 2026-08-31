import 'package:drift/drift.dart';

/// Current-state intention rows (PRD §7.1/§7.2).
///
/// Every column name is pinned explicitly with `.named(...)`. The native
/// capture path (PRD §5.4) inserts into this exact table without going through
/// Drift, so the physical names are a contract, not an implementation detail —
/// see `docs/native_db_contract.md`.
@DataClassName('IntentionRow')
class Intentions extends Table {
  @override
  String get tableName => 'intentions';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get sourceApp => text().named('source_app')();

  /// The Android package the promise was shared from, e.g.
  /// `com.whatsapp`. Nullable: an in-app capture has no source package, and a
  /// share whose sender cannot be attributed has none either.
  ///
  /// Stored so the UI can show the *real* launcher icon of the app a promise
  /// came from rather than an approximation — recognising WhatsApp's own icon
  /// in a list is instant in a way that a generic speech bubble never is.
  TextColumn get sourcePackage => text().named('source_package').nullable()();
  TextColumn get rawContent => text().named('raw_content')();
  TextColumn get snippet => text().named('snippet').nullable()();
  TextColumn get deepLink => text().named('deep_link').nullable()();
  DateTimeColumn get capturedAt => dateTime().named('captured_at')();
  DateTimeColumn get reminderAt => dateTime().named('reminder_at').nullable()();
  TextColumn get category => text().named('category').nullable()();
  TextColumn get status =>
      text().named('status').withDefault(const Constant('open'))();
  IntColumn get snoozeCount =>
      integer().named('snooze_count').withDefault(const Constant(0))();
  DateTimeColumn get extractedDeadline =>
      dateTime().named('extracted_deadline').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}

/// Append-only event log (PRD §7.1). Never updated, never deleted except when
/// its intention is deleted by the user.
@DataClassName('IntentionEventRow')
class IntentionEvents extends Table {
  @override
  String get tableName => 'intention_events';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get intentionId =>
      integer().named('intention_id').references(Intentions, #id)();
  TextColumn get type => text().named('type')();
  DateTimeColumn get occurredAt => dateTime().named('occurred_at')();
  TextColumn get metadata => text().named('metadata').nullable()();
}

/// Small key/value store for local, device-scoped settings (theme, display
/// name). Kept in the same SQLite file so there is exactly one local store
/// (PRD §3.3) rather than a second preferences mechanism.
@DataClassName('PreferenceRow')
class Preferences extends Table {
  @override
  String get tableName => 'preferences';

  TextColumn get key => text().named('key')();
  TextColumn get value => text().named('value')();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
