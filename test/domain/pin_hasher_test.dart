// PBKDF2-HMAC-SHA256, the thing standing between a stolen database file and
// four digits (ADR-010).

import 'dart:convert';
import 'dart:typed_data';

import 'package:cya/domain/services/pin_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Uint8List bytes(String value) => Uint8List.fromList(utf8.encode(value));

  String hex(Uint8List value) =>
      value.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  group('PBKDF2-HMAC-SHA256 (RFC 8018)', () {
    // Published vectors. The point of asserting these rather than a
    // round-trip is that a *wrong* KDF round-trips perfectly well — it just
    // isn't the one whose cost anyone has ever measured.
    test('matches the published vector at one iteration', () {
      final credential = PinHasher.derive(
        'password',
        bytes('salt'),
        iterations: 1,
      );
      expect(
        hex(credential.hash),
        '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
      );
    });

    test('matches the published vector at two iterations', () {
      expect(
        hex(PinHasher.derive('password', bytes('salt'), iterations: 2).hash),
        'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43',
      );
    });

    test('matches the published vector at 4096 iterations', () {
      expect(
        hex(PinHasher.derive('password', bytes('salt'), iterations: 4096).hash),
        'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
      );
    });
  });

  group('credentials', () {
    test('accepts the right PIN and rejects every other one', () {
      final credential = PinHasher.derive(
        '4821',
        PinHasher.newSalt(),
        iterations: 64,
      );
      expect(PinHasher.matches('4821', credential), isTrue);
      expect(PinHasher.matches('4822', credential), isFalse);
      expect(PinHasher.matches('482', credential), isFalse);
      expect(PinHasher.matches('', credential), isFalse);
    });

    test('the same PIN on two devices produces different hashes', () {
      // Without this, one precomputed table of ten thousand hashes would open
      // every install at once.
      final a = PinHasher.derive('1234', PinHasher.newSalt(), iterations: 64);
      final b = PinHasher.derive('1234', PinHasher.newSalt(), iterations: 64);
      expect(hex(a.salt), isNot(hex(b.salt)));
      expect(hex(a.hash), isNot(hex(b.hash)));
    });

    test('carries the cost it was derived at, so it can be raised later', () {
      final credential = PinHasher.derive(
        '1234',
        PinHasher.newSalt(),
        iterations: 77,
      );
      expect(credential.iterations, 77);
      // Verification uses the stored cost, not today's default — otherwise
      // raising the default would lock out every existing PIN.
      expect(PinHasher.matches('1234', credential), isTrue);
    });

    test('the default cost is high enough to make guessing expensive', () {
      // A four-digit PIN has ten thousand values; the only defence against an
      // offline attacker is what each guess costs.
      expect(PinHasher.defaultIterations, greaterThanOrEqualTo(100000));
    });
  });
}
