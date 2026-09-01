import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/repositories/preference_lock_repository.dart';
import '../../domain/entities/lock_settings.dart';
import '../../domain/repositories/lock_repository.dart';
import '../../native/biometric_port.dart';

/// Local identity: the device lock, and whether this session has opened it
/// (ADR-010 — no account, no server, nothing to sign in to).

final lockRepositoryProvider = Provider<LockRepository>(
  (ref) => PreferenceLockRepository(
    ref.watch(preferenceDaoProvider),
    ref.watch(clockProvider),
  ),
);

final lockSettingsProvider = StreamProvider<LockSettings>(
  (ref) => ref.watch(lockRepositoryProvider).watch(),
);

final biometricPortProvider = Provider<BiometricPort>(
  (ref) => const BiometricPort(),
);

/// Whether a fingerprint can be offered. Asked once per app start: enrolling a
/// print mid-session is rare, and re-asking on every rebuild would flash the
/// switch.
final biometricAvailabilityProvider = FutureProvider<BiometricAvailability>(
  (ref) => ref.watch(biometricPortProvider).availability(),
);

/// Whether this *session* still needs the PIN.
///
/// Starts locked and is cleared by a successful unlock. Deliberately session
/// state rather than a stored flag: "unlocked" must not survive the process,
/// or the lock would only ever be asked for once on the device.
class SessionLock extends Notifier<bool> {
  @override
  bool build() => true;

  void unlock() => state = false;

  void lock() => state = true;
}

final sessionLockProvider = NotifierProvider<SessionLock, bool>(
  SessionLock.new,
);

/// Whether the lock screen should be in front of the user right now.
///
/// Resolves to `false` while the store is still answering, so a device with no
/// PIN never flashes a lock screen on the way to Home — the cost of being wrong
/// for one frame in the other direction (briefly showing a locked app's
/// content) is the one worth avoiding, and `hasPin` arrives from the same
/// SQLite read that gates the router.
final lockGateProvider = Provider<bool>((ref) {
  final settings = ref.watch(lockSettingsProvider).valueOrNull;
  return (settings?.hasPin ?? false) && ref.watch(sessionLockProvider);
});
