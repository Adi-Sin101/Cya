import 'dart:typed_data';

/// A PIN, stored the only way a PIN may be stored: salted, stretched, and
/// never recoverable (ADR-010).
///
/// There is no account and therefore no reset path, which makes an offline
/// guessing attack against the device's own database file the entire threat
/// model. A bare SHA-256 of four digits falls to that in microseconds, so the
/// digits go through PBKDF2-HMAC-SHA256 with a per-device random salt — see
/// `PinHasher`. [iterations] is stored alongside the hash so the cost can be
/// raised later without invalidating PINs already set.
class PinCredential {
  const PinCredential({
    required this.salt,
    required this.hash,
    required this.iterations,
  });

  final Uint8List salt;
  final Uint8List hash;
  final int iterations;
}

/// Whether this device's promises are locked, and how they may be opened.
///
/// A value object, not a snapshot of the credential: nothing outside the lock
/// repository ever needs the hash, so nothing outside it ever sees one.
class LockSettings {
  const LockSettings({required this.hasPin, required this.biometricEnabled});

  /// The state of a device that has never been locked.
  static const LockSettings open = LockSettings(
    hasPin: false,
    biometricEnabled: false,
  );

  final bool hasPin;

  /// Whether the fingerprint shortcut is offered. Meaningless without a PIN —
  /// biometrics are a way to skip typing it, never a replacement for having
  /// one, because a device whose biometric hardware is unavailable must still
  /// be openable by the person who owns it.
  final bool biometricEnabled;

  bool get isLocked => hasPin;

  LockSettings copyWith({bool? hasPin, bool? biometricEnabled}) => LockSettings(
    hasPin: hasPin ?? this.hasPin,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
  );

  @override
  bool operator ==(Object other) =>
      other is LockSettings &&
      other.hasPin == hasPin &&
      other.biometricEnabled == biometricEnabled;

  @override
  int get hashCode => Object.hash(hasPin, biometricEnabled);
}

/// The outcome of offering a PIN.
///
/// Sealed rather than a bool because "wrong" and "too many wrong, wait" are
/// different things to the person typing, and the screen has to say which.
sealed class PinVerdict {
  const PinVerdict();
}

class PinAccepted extends PinVerdict {
  const PinAccepted();
}

/// Wrong PIN. [attemptsRemaining] counts down to the next cooldown, so the UI
/// can warn before it happens rather than after.
class PinRejected extends PinVerdict {
  const PinRejected(this.attemptsRemaining);

  final int attemptsRemaining;
}

/// Too many wrong PINs. No attempt was checked; try again in [remaining].
class PinCooldown extends PinVerdict {
  const PinCooldown(this.remaining);

  final Duration remaining;
}
