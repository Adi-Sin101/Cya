import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import '../dao/intention_dao.dart';
import '../dao/preference_dao.dart';
import 'tables.dart';

part 'cya_database.g.dart';

/// The one local SQLite store — the single source of truth (PRD §3.3).
///
/// The same physical file is opened by the native capture path (PRD §5.2/§5.4),
/// so the schema, the file name and the on-disk value encodings are a
/// cross-runtime contract documented in `docs/native_db_contract.md`.
@DriftDatabase(
  tables: [Intentions, IntentionEvents, Preferences],
  daos: [IntentionDao, PreferenceDao],
)
class CyaDatabase extends _$CyaDatabase {
  CyaDatabase() : super(_openConnection());

  /// Test seam: an isolated in-memory database.
  CyaDatabase.memory() : super(NativeDatabase.memory());

  CyaDatabase.forTesting(super.executor);

  /// The file name shared with the native writer. Never rename without a
  /// coordinated migration on both runtimes.
  static const String databaseFileName = 'cya.db';

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createHotPathIndices();
    },
    beforeOpen: (details) async {
      // Foreign keys are off by default in SQLite and must be enabled per
      // connection.
      await customStatement('PRAGMA foreign_keys = ON');
      // The database may have been created by the native capture path, which
      // does not know about search at all (ADR-005) — so the index is ensured
      // and reconciled here, on every open, rather than at creation time.
      await reconcileSearchIndex();
    },
  );

  /// FTS5 index backing V1 on-device search (PRD §6.4).
  ///
  /// **Dart owns this index, not the database.** Android's system SQLite — the
  /// one the native capture path uses — has no FTS5 module (verified on API 34),
  /// so trigger-based maintenance would make every native insert fail. The
  /// native path therefore writes plain rows, and this side catches the index up
  /// on open and before every search (ADR-005).
  ///
  /// Progress is tracked with a watermark (the highest intention id already
  /// indexed) rather than by comparing row counts: an external-content FTS5
  /// table reads its values *from* the content table, so `COUNT(*)` on it always
  /// equals the content table's count and would report a stale index as fresh.
  Future<void> reconcileSearchIndex() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS intentions_fts USING fts5(
        raw_content,
        snippet,
        content='intentions',
        content_rowid='id'
      )''');

    final indexedThrough = await _readIndexedWatermark();
    if (indexedThrough == null) {
      // Unknown state (a database created by the native path, or an upgrade
      // from before the index existed): index everything once.
      await rebuildSearchIndex();
      return;
    }

    final row = await customSelect(
      'SELECT COALESCE(MAX(id), 0) AS max_id FROM intentions',
    ).getSingle();
    final maxId = row.read<int>('max_id');
    if (maxId <= indexedThrough) return;

    await customStatement(
      'INSERT INTO intentions_fts(rowid, raw_content, snippet) '
      "SELECT id, raw_content, COALESCE(snippet, '') FROM intentions "
      'WHERE id > ?1',
      <Object?>[indexedThrough],
    );
    await _writeIndexedWatermark(maxId);
  }

  /// Reindexes everything from the content table. Used after edits and
  /// deletions — rare operations where correctness beats incrementalism.
  Future<void> rebuildSearchIndex() async {
    await customStatement(
      "INSERT INTO intentions_fts(intentions_fts) VALUES('rebuild')",
    );
    final row = await customSelect(
      'SELECT COALESCE(MAX(id), 0) AS max_id FROM intentions',
    ).getSingle();
    await _writeIndexedWatermark(row.read<int>('max_id'));
  }

  static const String _indexWatermarkKey = 'fts_indexed_through_id';

  Future<int?> _readIndexedWatermark() async {
    final rows = await customSelect(
      'SELECT value FROM preferences WHERE key = ?1',
      variables: [Variable<String>(_indexWatermarkKey)],
    ).get();
    if (rows.isEmpty) return null;
    return int.tryParse(rows.first.read<String>('value'));
  }

  Future<void> _writeIndexedWatermark(int value) => customStatement(
    'INSERT INTO preferences(key, value) VALUES(?1, ?2) '
    'ON CONFLICT(key) DO UPDATE SET value = excluded.value',
    <Object?>[_indexWatermarkKey, '$value'],
  );

  /// The two columns every hot query filters on (today's promises, due alarms).
  Future<void> _createHotPathIndices() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_intentions_status ON intentions(status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_intentions_reminder_at '
      'ON intentions(reminder_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_intention_events_occurred_at '
      'ON intention_events(occurred_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_intention_events_intention '
      'ON intention_events(intention_id)',
    );
  }
}

/// Opens the shared database file.
///
/// Application-support is used (not the cache or a Flutter-private location)
/// because it maps to app-private storage the native layer can reach with
/// `context.filesDir` on Android.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}'
      '${CyaDatabase.databaseFileName}',
    );
    return NativeDatabase.createInBackground(file);
  });
}
