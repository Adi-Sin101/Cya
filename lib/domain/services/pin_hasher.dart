import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../entities/lock_settings.dart';

/// Turns a PIN into something safe to leave on disk (ADR-010).
///
/// PBKDF2-HMAC-SHA256, per RFC 8018. The choice is forced by the product: with
/// no account there is no reset, so an attacker with the device's database file
/// is the whole threat model, and a four-digit PIN has only ten thousand
/// possible values. Stretching does not make that space bigger — nothing can —
/// it makes each guess cost something. At [defaultIterations] the full space
/// costs on the order of a billion HMAC operations, which turns "instant" into
/// "hours", and the app's own cooldown (see `LockRepository`) covers the online
/// case.
///
/// Pure Dart with no Flutter import, so it can run wherever it is cheapest to
/// run — in practice a background isolate, because a deliberately slow function
/// on the UI thread is a dropped frame by design (PRD §9.1).
abstract final class PinHasher {
  const PinHasher._();

  /// Tuned so a single derivation stays comfortably under the ~300ms a person
  /// will accept when unlocking, on the low end of the target hardware.
  /// Stored per credential, so raising this later re-costs new PINs without
  /// locking anyone out of an old one.
  static const int defaultIterations = 100000;

  static const int _saltBytes = 16;
  static const int _keyBytes = 32;

  /// A fresh salt. [Random.secure] rather than [Random] — a predictable salt is
  /// no salt, and one shared table of precomputed hashes would break every
  /// install at once.
  static Uint8List newSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(_saltBytes, (_) => random.nextInt(256)),
    );
  }

  /// Derives the credential for [pin]. Slow on purpose.
  static PinCredential derive(
    String pin,
    Uint8List salt, {
    int iterations = defaultIterations,
  }) {
    return PinCredential(
      salt: salt,
      hash: _pbkdf2(pin.codeUnits, salt, iterations, _keyBytes),
      iterations: iterations,
    );
  }

  /// Whether [pin] produces [credential]. Compares in constant time so the
  /// answer leaks nothing about how nearly right a guess was.
  static bool matches(String pin, PinCredential credential) {
    final candidate = _pbkdf2(
      pin.codeUnits,
      credential.salt,
      credential.iterations,
      credential.hash.length,
    );
    return _constantTimeEquals(candidate, credential.hash);
  }

  static Uint8List _pbkdf2(
    List<int> password,
    Uint8List salt,
    int iterations,
    int keyLength,
  ) {
    final hmac = Hmac(sha256, password);
    final derived = Uint8List(keyLength);
    final blockCount = (keyLength / _keyBytes).ceil();

    for (var block = 1; block <= blockCount; block++) {
      // U1 = PRF(password, salt || INT_32_BE(block))
      final seed = Uint8List(salt.length + 4)
        ..setRange(0, salt.length, salt)
        ..buffer.asByteData().setUint32(salt.length, block);

      var u = Uint8List.fromList(hmac.convert(seed).bytes);
      final accumulator = Uint8List.fromList(u);
      // T = U1 xor U2 xor ... xor Uc
      for (var round = 1; round < iterations; round++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var i = 0; i < accumulator.length; i++) {
          accumulator[i] ^= u[i];
        }
      }

      final offset = (block - 1) * _keyBytes;
      final take = min(_keyBytes, keyLength - offset);
      derived.setRange(offset, offset + take, accumulator);
    }
    return derived;
  }

  /// XOR-accumulating comparison: always touches every byte, so its runtime
  /// does not depend on where the first difference is.
  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}
