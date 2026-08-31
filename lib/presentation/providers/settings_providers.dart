import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/dao/preference_dao.dart';

/// Device-scoped settings, stored in the same SQLite file as the promises so
/// the app keeps exactly one local store (PRD §3.3).

final _themeModeStreamProvider = StreamProvider<ThemeMode>(
  (ref) => ref
      .watch(preferenceDaoProvider)
      .watch(PreferenceDao.keyThemeMode)
      .map(_parseThemeMode),
);

/// The active theme. Falls back to the system setting until the store answers,
/// so the first frame never waits on disk.
final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(_themeModeStreamProvider).valueOrNull ?? ThemeMode.system,
);

final displayNameProvider = StreamProvider<String?>(
  (ref) => ref.watch(preferenceDaoProvider).watch(PreferenceDao.keyDisplayName),
);

/// Writes settings. Reads flow back through the streams above, so the UI has a
/// single direction of data (PRD §3.3).
class SettingsController {
  const SettingsController(this._dao);

  final PreferenceDao _dao;

  Future<void> setThemeMode(ThemeMode mode) =>
      _dao.write(PreferenceDao.keyThemeMode, mode.name);

  Future<void> setDisplayName(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty
        ? _dao.remove(PreferenceDao.keyDisplayName)
        : _dao.write(PreferenceDao.keyDisplayName, trimmed);
  }
}

final settingsControllerProvider = Provider<SettingsController>(
  (ref) => SettingsController(ref.watch(preferenceDaoProvider)),
);

ThemeMode _parseThemeMode(String? stored) => switch (stored) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};
