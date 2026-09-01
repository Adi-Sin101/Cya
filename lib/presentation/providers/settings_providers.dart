import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/dao/preference_dao.dart';
import '../../domain/enums/profile_avatar.dart';

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

final _avatarStreamProvider = StreamProvider<ProfileAvatar>(
  (ref) => ref
      .watch(preferenceDaoProvider)
      .watch(PreferenceDao.keyAvatar)
      .map(ProfileAvatar.fromId),
);

/// The glyph that greets the user. Falls back to the mascot until the store
/// answers, so the first frame never waits on disk.
final profileAvatarProvider = Provider<ProfileAvatar>(
  (ref) =>
      ref.watch(_avatarStreamProvider).valueOrNull ?? ProfileAvatar.fallback,
);

/// Whether the four onboarding steps have been seen (PRD §8.1, ADR-010).
///
/// `null` while the store is still answering — the router must not send a
/// returning user through onboarding just because disk was a frame slow, so the
/// unknown state is distinct from `false` and is held on the splash.
final onboardingCompleteProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(preferenceDaoProvider)
      .watch(PreferenceDao.keyOnboardingComplete)
      .map((value) => value == 'true'),
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

  Future<void> setAvatar(ProfileAvatar avatar) =>
      _dao.write(PreferenceDao.keyAvatar, avatar.id);

  Future<void> setOnboardingComplete({bool complete = true}) =>
      _dao.write(PreferenceDao.keyOnboardingComplete, '$complete');
}

final settingsControllerProvider = Provider<SettingsController>(
  (ref) => SettingsController(ref.watch(preferenceDaoProvider)),
);

ThemeMode _parseThemeMode(String? stored) => switch (stored) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};
