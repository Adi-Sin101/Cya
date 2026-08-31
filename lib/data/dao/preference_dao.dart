import 'package:drift/drift.dart';

import '../db/cya_database.dart';
import '../db/tables.dart';

part 'preference_dao.g.dart';

/// Device-scoped settings, stored in the same SQLite file as everything else so
/// the app has exactly one local store (PRD §3.3).
@DriftAccessor(tables: [Preferences])
class PreferenceDao extends DatabaseAccessor<CyaDatabase>
    with _$PreferenceDaoMixin {
  PreferenceDao(super.db);

  static const String keyThemeMode = 'theme_mode';
  static const String keyDisplayName = 'display_name';
  static const String keySeeded = 'demo_seeded';

  Stream<String?> watch(String key) {
    final query = select(preferences)..where((t) => t.key.equals(key));
    return query.watchSingleOrNull().map((row) => row?.value);
  }

  Future<String?> read(String key) async {
    final query = select(preferences)..where((t) => t.key.equals(key));
    final row = await query.getSingleOrNull();
    return row?.value;
  }

  Future<void> write(String key, String value) {
    return into(
      preferences,
    ).insertOnConflictUpdate(PreferenceRow(key: key, value: value));
  }

  Future<void> remove(String key) {
    return (delete(preferences)..where((t) => t.key.equals(key))).go();
  }
}
