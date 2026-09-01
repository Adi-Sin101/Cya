import '../entities/lock_settings.dart';

/// The device-local lock (ADR-010).
///
/// Everything here is answered by the device. There is no account to
/// authenticate against, no token to refresh and no server that could be down
/// between someone and their own promises — which is the point: a lock that can
/// fail closed because a network failed is worse than no lock at all.
abstract interface class LockRepository {
  /// The current lock state, reactively. Never exposes the credential itself.
  Stream<LockSettings> watch();

  Future<LockSettings> read();

  /// Sets or replaces the PIN. Deriving it is deliberately expensive, so this
  /// is the one call in the flow allowed to take a visible moment.
  Future<void> setPin(String pin);

  /// Checks [pin], applying the failed-attempt cooldown. A rejected attempt
  /// counts; an attempt made during a cooldown does not, so waiting out a
  /// cooldown never costs an extra try.
  Future<PinVerdict> verify(String pin);

  /// Removes the lock entirely, credential and all.
  Future<void> disable();

  /// Turns the fingerprint shortcut on or off. A no-op without a PIN.
  Future<void> setBiometricEnabled(bool enabled);
}
