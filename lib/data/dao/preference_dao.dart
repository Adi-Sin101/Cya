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

  /// Which glyph greets the user (see `ProfileAvatar`).
  static const String keyAvatar = 'profile_avatar';

  /// Set once the four onboarding steps have been seen. Its absence is what
  /// routes a fresh install to onboarding, so it is the one preference whose
  /// *missing* state is meaningful.
  static const String keyOnboardingComplete = 'onboarding_complete';

  // --- Device lock (ADR-010). Written only by `PreferenceLockRepository`. ---
  static const String keyPinSalt = 'lock_pin_salt';
  static const String keyPinHash = 'lock_pin_hash';
  static const String keyPinIterations = 'lock_pin_iterations';
  static const String keyPinBiometric = 'lock_biometric';
  static const String keyPinFailures = 'lock_failed_attempts';
  static const String keyPinCooldownUntil = 'lock_cooldown_until';

  /// Autostart cannot be read back from any OEM, so the reliability checklist
  /// records that the user said they did it. A claim, not a measurement — and
  /// the reboot test in PRD §10 is what actually verifies it.
  static const String keyAutostartConfirmed = 'reliability_autostart_confirmed';

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

  /// Every stored setting. Feeds the data export, which filters the lock's
  /// secrets out one layer up (see `DataExport.redactedPreferenceKeys`).
  Future<Map<String, String>> all() async {
    final rows = await select(preferences).get();
    return <String, String>{for (final row in rows) row.key: row.value};
  }

  /// Wipes every setting — the profile, the theme, the lock, the search
  /// watermark (PRD §9.3).
  ///
  /// Deliberately total. "Delete all my data" that leaves a name and a PIN
  /// behind is not the thing it says it is, and the search index's watermark
  /// has to go with the rows it described or the next capture is indexed
  /// against a number from a database that no longer exists.
  Future<void> clearAll() => delete(preferences).go();
}
