import 'package:cya/data/db/cya_database.dart';
import 'package:cya/domain/enums/intention_event_type.dart';
import 'package:cya/domain/enums/intention_status.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Guards the two-runtime contract in `docs/native_db_contract.md`.
///
/// The native capture path (PRD §5.4) writes into this database without Drift. If the Kotlin DDL and
/// the Drift schema ever disagree, captures are silently lost — so this test creates a database
/// exactly the way `CyaDatabaseContract.kt` does, hands it to Drift, and asserts Drift accepts it
/// as-is and can read what native wrote.
///
/// **Keep this DDL in step with `CyaDatabaseContract.CREATE_STATEMENTS`.** Note what is *absent*:
/// no FTS5 table and no triggers. Android's system SQLite has no fts5 module (verified on API 34),
/// so the search index is Dart-owned and reconciled on open (ADR-005).
const List<String> _nativeCreateStatements = <String>[
  '''
CREATE TABLE IF NOT EXISTS "intentions" (
  "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  "source_app" TEXT NOT NULL,
  "raw_content" TEXT NOT NULL,
  "snippet" TEXT NULL,
  "deep_link" TEXT NULL,
  "captured_at" INTEGER NOT NULL,
  "reminder_at" INTEGER NULL,
  "category" TEXT NULL,
  "status" TEXT NOT NULL DEFAULT 'open',
  "snooze_count" INTEGER NOT NULL DEFAULT 0,
  "extracted_deadline" INTEGER NULL,
  "updated_at" INTEGER NOT NULL
)''',
  '''
CREATE TABLE IF NOT EXISTS "intention_events" (
  "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  "intention_id" INTEGER NOT NULL REFERENCES intentions (id),
  "type" TEXT NOT NULL,
  "occurred_at" INTEGER NOT NULL,
  "metadata" TEXT NULL
)''',
  '''
CREATE TABLE IF NOT EXISTS "preferences" (
  "key" TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("key")
)''',
  'CREATE INDEX IF NOT EXISTS idx_intentions_status ON intentions(status)',
  'CREATE INDEX IF NOT EXISTS idx_intentions_reminder_at ON intentions(reminder_at)',
  'CREATE INDEX IF NOT EXISTS idx_intention_events_occurred_at '
      'ON intention_events(occurred_at)',
  'CREATE INDEX IF NOT EXISTS idx_intention_events_intention '
      'ON intention_events(intention_id)',
];

void main() {
  late Database native;
  final capturedAt = DateTime(2026, 3, 4, 18, 30);
  final reminderAt = DateTime(2026, 3, 4, 20);

  /// Reproduces what `CaptureWriter` does on a device that has never run the app.
  void nativeCapture({
    String sourceApp = 'Messenger',
    String rawContent = 'Reply to Sarah about Saturday',
    String? snippet = 'are we still on?',
    String? deepLink,
  }) {
    native
      ..execute('BEGIN')
      ..execute(
        'INSERT INTO intentions (source_app, raw_content, snippet, deep_link, '
        'captured_at, reminder_at, status, snooze_count, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          sourceApp,
          rawContent,
          snippet,
          deepLink,
          capturedAt.millisecondsSinceEpoch ~/ 1000,
          reminderAt.millisecondsSinceEpoch ~/ 1000,
          IntentionStatus.open.wire,
          0,
          capturedAt.millisecondsSinceEpoch ~/ 1000,
        ],
      )
      ..execute(
        'INSERT INTO intention_events (intention_id, type, occurred_at, metadata) '
        'VALUES (last_insert_rowid(), ?, ?, ?)',
        <Object?>[
          IntentionEventType.captured.wire,
          capturedAt.millisecondsSinceEpoch ~/ 1000,
          '{"source":"$sourceApp","surface":"share_sheet","capture_ms":42}',
        ],
      )
      ..execute('COMMIT');
  }

  setUp(() {
    native = sqlite3.openInMemory();
    for (final statement in _nativeCreateStatements) {
      native.execute(statement);
    }
    native.execute('PRAGMA user_version = 1');
  });

  tearDown(() => native.close());

  test('native DDL yields the schema version Drift expects', () {
    final drift = CyaDatabase.memory();
    addTearDown(drift.close);
    final version = native.select('PRAGMA user_version').first.values.first;
    expect(version, drift.schemaVersion);
  });

  test('Drift opens a native-created database without migrating it', () async {
    nativeCapture();

    final db = CyaDatabase.forTesting(
      NativeDatabase.opened(native, closeUnderlyingOnClose: false),
    );
    addTearDown(db.close);
    // Reading forces Drift to open the file, running its migration strategy.
    final promises = await db.intentionDao.watchAllActive().first;

    // Still at version 1: Drift accepted the native schema instead of creating
    // or upgrading anything, and the natively written row survived untouched.
    final version = native.select('PRAGMA user_version').first.values.first;
    expect(version, 1);
    expect(promises, hasLength(1));
    final promise = promises.single;
    expect(promise.sourceApp, 'Messenger');
    expect(promise.title, 'Reply to Sarah about Saturday');
    expect(promise.status, IntentionStatus.open);
    // The encoding contract: seconds, not millis. A millis/seconds mix-up would
    // land this promise ~55,000 years away.
    expect(promise.capturedAt, capturedAt);
    expect(promise.reminderAt, reminderAt);
  });

  test('a natively written capture is searchable and logged', () async {
    nativeCapture();
    final db = CyaDatabase.forTesting(
      NativeDatabase.opened(native, closeUnderlyingOnClose: false),
    );
    addTearDown(db.close);

    // Native wrote no index entry — reconciliation on open/search finds it.
    expect(await db.intentionDao.search('sarah'), hasLength(1));

    final counts = await db.intentionDao.watchEventCounts().first;
    expect(counts[IntentionEventType.captured], 1);

    final events = await db.intentionDao.watchEventsFor(1).first;
    expect(events.single.metadata, contains('"surface":"share_sheet"'));
    expect(events.single.metadata, contains('capture_ms'));
  });

  test('native writes made while the app is open are still found', () async {
    final db = CyaDatabase.forTesting(
      NativeDatabase.opened(native, closeUnderlyingOnClose: false),
    );
    addTearDown(db.close);
    // App running, index warm...
    expect(await db.intentionDao.search('cable'), isEmpty);

    // ...then a share arrives and the native path writes straight to the file.
    nativeCapture(rawContent: 'Buy an HDMI cable', snippet: null);

    expect(await db.intentionDao.search('cable'), hasLength(1));
  });

  test('the native path never needs the fts5 module', () {
    // The DDL the Kotlin writer runs must be executable by a SQLite build
    // without fts5 — which is what Android ships.
    for (final statement in _nativeCreateStatements) {
      expect(statement.toLowerCase(), isNot(contains('fts')));
    }
  });

  test('Dart and native agree on the wire vocabularies', () {
    // These literals are what CyaDatabaseContract.kt writes.
    expect(IntentionStatus.open.wire, 'open');
    expect(IntentionStatus.snoozed.wire, 'snoozed');
    expect(IntentionStatus.resolved.wire, 'resolved');
    expect(IntentionStatus.archived.wire, 'archived');
    expect(IntentionEventType.captured.wire, 'captured');
    expect(IntentionEventType.resolved.wire, 'resolved');
    expect(IntentionEventType.snoozed.wire, 'snoozed');
    expect(IntentionEventType.resurfaced.wire, 'resurfaced');
  });

  test('the app can act on a natively captured promise', () async {
    nativeCapture();
    final db = CyaDatabase.forTesting(
      NativeDatabase.opened(native, closeUnderlyingOnClose: false),
    );
    addTearDown(db.close);

    await db.intentionDao.resolve(1, at: capturedAt);

    expect((await db.intentionDao.findById(1))!.isResolved, isTrue);
    final events = await db.intentionDao.watchEventsFor(1).first;
    expect(events.map((e) => e.type), <IntentionEventType>[
      IntentionEventType.captured,
      IntentionEventType.resolved,
    ]);
  });
}
