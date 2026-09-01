import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import '../../core/utils/clock.dart';
import '../../domain/entities/lock_settings.dart';
import '../../domain/repositories/lock_repository.dart';
import '../../domain/services/pin_hasher.dart';
import '../dao/preference_dao.dart';

/// [LockRepository] over the same SQLite file as everything else (PRD §3.3).
///
/// The credential lives in `preferences` rather than in a separate secure store
/// because a PBKDF2 hash is already safe at rest, and a second storage
/// mechanism would be a second thing to migrate, back up and get wrong. What
/// protects the *contents* of the database is encryption at rest, which is a
/// different job (ADR-010) from proving who is holding the phone.
/// Runs [work] somewhere, and returns what it produced.
///
/// The seam exists because PBKDF2 is *meant* to be slow, so in the app it has
/// to leave the UI isolate — and a cross-isolate future never completes inside
/// a widget test's fake-async zone, which would make the whole unlock flow
/// untestable above the repository. See [PreferenceLockRepository.inlineWorker].
typedef PinWorker = Future<T> Function<T>(T Function() work);

Future<T> _isolateWorker<T>(T Function() work) => Isolate.run(work);

class PreferenceLockRepository implements LockRepository {
  PreferenceLockRepository(
    this._preferences,
    this._clock, {
    this.iterations = PinHasher.defaultIterations,
    this.worker = _isolateWorker,
  });

  /// Runs the derivation on the calling isolate.
  ///
  /// Correct only where the cost is small — a widget test with a low
  /// [iterations]. At the production cost this would drop every frame of the
  /// unlock animation, which is the reason the default is an isolate.
  static Future<T> inlineWorker<T>(T Function() work) async => work();

  final PreferenceDao _preferences;
  final Clock _clock;

  /// The PBKDF2 cost for PINs set from here.
  ///
  /// Stored alongside each credential, so this can be raised for new PINs on
  /// faster hardware without invalidating one already set. Lowered in tests,
  /// which assert the *policy* — cooldowns, verdicts, disabling — and would
  /// otherwise spend their whole runtime proving that a slow hash is slow.
  final int iterations;

  /// Where the derivation runs. A background isolate in the app.
  final PinWorker worker;

  /// Wrong PINs allowed before the first cooldown. Generous enough to survive a
  /// pocket-tap, tight enough that ten thousand guesses is not an afternoon.
  static const int attemptsBeforeCooldown = 5;

  static const Duration _firstCooldown = Duration(seconds: 30);

  /// Each further round of failures doubles the wait, up to here. Capped
  /// because the person locked out is overwhelmingly the owner who mistyped,
  /// and an unbounded lockout punishes them, not an attacker with the file.
  static const Duration _maxCooldown = Duration(minutes: 5);

  @override
  Stream<LockSettings> watch() {
    // The credential's presence is what "locked" means, so the hash row is the
    // one to watch; the biometric flag is read alongside it.
    return _preferences.watch(PreferenceDao.keyPinHash).asyncMap((hash) async {
      final biometric = await _preferences.read(PreferenceDao.keyPinBiometric);
      return LockSettings(
        hasPin: hash != null && hash.isNotEmpty,
        biometricEnabled: biometric == 'true',
      );
    });
  }

  @override
  Future<LockSettings> read() async {
    final hash = await _preferences.read(PreferenceDao.keyPinHash);
    final biometric = await _preferences.read(PreferenceDao.keyPinBiometric);
    return LockSettings(
      hasPin: hash != null && hash.isNotEmpty,
      biometricEnabled: biometric == 'true',
    );
  }

  @override
  Future<void> setPin(String pin) async {
    final credential = await _derive(pin, PinHasher.newSalt());
    await _preferences.write(
      PreferenceDao.keyPinSalt,
      base64Encode(credential.salt),
    );
    await _preferences.write(
      PreferenceDao.keyPinHash,
      base64Encode(credential.hash),
    );
    await _preferences.write(
      PreferenceDao.keyPinIterations,
      '${credential.iterations}',
    );
    await _clearFailures();
  }

  @override
  Future<PinVerdict> verify(String pin) async {
    final now = _clock();
    final until = await _cooldownUntil();
    if (until != null && until.isAfter(now)) {
      return PinCooldown(until.difference(now));
    }

    final credential = await _readCredential();
    // No credential means no lock; treat it as open rather than as a failure,
    // so a half-written state can never strand someone outside their promises.
    if (credential == null) return const PinAccepted();

    if (await _matches(pin, credential)) {
      await _clearFailures();
      return const PinAccepted();
    }
    return _recordFailure(now);
  }

  @override
  Future<void> disable() async {
    await _preferences.remove(PreferenceDao.keyPinSalt);
    await _preferences.remove(PreferenceDao.keyPinHash);
    await _preferences.remove(PreferenceDao.keyPinIterations);
    await _preferences.remove(PreferenceDao.keyPinBiometric);
    await _clearFailures();
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) =>
      _preferences.write(PreferenceDao.keyPinBiometric, '$enabled');

  // --- internals ---

  Future<PinCredential?> _readCredential() async {
    final salt = await _preferences.read(PreferenceDao.keyPinSalt);
    final hash = await _preferences.read(PreferenceDao.keyPinHash);
    if (salt == null || hash == null) return null;
    final iterations =
        int.tryParse(
          await _preferences.read(PreferenceDao.keyPinIterations) ?? '',
        ) ??
        PinHasher.defaultIterations;
    return PinCredential(
      salt: Uint8List.fromList(base64Decode(salt)),
      hash: Uint8List.fromList(base64Decode(hash)),
      iterations: iterations,
    );
  }

  /// Runs the deliberately slow derivation off the UI isolate. The whole point
  /// of PBKDF2 is to burn time; burning it on the platform thread would drop
  /// every frame of the unlock animation (PRD §9.1).
  Future<PinCredential> _derive(String pin, Uint8List salt) {
    final cost = iterations;
    return worker(() => PinHasher.derive(pin, salt, iterations: cost));
  }

  Future<bool> _matches(String pin, PinCredential credential) =>
      worker(() => PinHasher.matches(pin, credential));

  Future<PinVerdict> _recordFailure(DateTime now) async {
    final failures =
        (int.tryParse(
          await _preferences.read(PreferenceDao.keyPinFailures) ?? '',
        ) ??
        0) +
        1;
    await _preferences.write(PreferenceDao.keyPinFailures, '$failures');

    if (failures % attemptsBeforeCooldown != 0) {
      return PinRejected(attemptsBeforeCooldown - (failures % attemptsBeforeCooldown));
    }

    // Every full round of failures doubles the wait: 30s, 1m, 2m, 4m, 5m…
    final rounds = failures ~/ attemptsBeforeCooldown;
    final scaled = _firstCooldown * (1 << (rounds - 1).clamp(0, 8));
    final cooldown = scaled > _maxCooldown ? _maxCooldown : scaled;
    await _preferences.write(
      PreferenceDao.keyPinCooldownUntil,
      now.add(cooldown).toIso8601String(),
    );
    return PinCooldown(cooldown);
  }

  Future<DateTime?> _cooldownUntil() async {
    final stored = await _preferences.read(PreferenceDao.keyPinCooldownUntil);
    return stored == null ? null : DateTime.tryParse(stored);
  }

  Future<void> _clearFailures() async {
    await _preferences.remove(PreferenceDao.keyPinFailures);
    await _preferences.remove(PreferenceDao.keyPinCooldownUntil);
  }
}
