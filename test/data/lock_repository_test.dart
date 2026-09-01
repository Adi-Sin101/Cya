// The device lock's policy: what a PIN opens, and what happens when it doesn't
// (ADR-010).

import 'package:cya/data/dao/preference_dao.dart';
import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/preference_lock_repository.dart';
import 'package:cya/domain/entities/lock_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CyaDatabase db;
  late DateTime now;
  late PreferenceLockRepository lock;

  setUp(() {
    db = CyaDatabase.memory();
    now = DateTime(2026, 9, 1, 20);
    lock = PreferenceLockRepository(
      db.preferenceDao,
      () => now,
      // The stretching itself is proved in pin_hasher_test.dart; these tests
      // are about the rules around it.
      iterations: 64,
    );
  });

  tearDown(() => db.close());

  Future<void> failTimes(int count) async {
    for (var i = 0; i < count; i++) {
      await lock.verify('0000');
    }
  }

  group('setting a PIN', () {
    test('a device with no PIN is open', () async {
      expect(await lock.read(), LockSettings.open);
    });

    test('setting one locks the device and accepts it back', () async {
      await lock.setPin('4821');

      expect((await lock.read()).hasPin, isTrue);
      expect(await lock.verify('4821'), isA<PinAccepted>());
    });

    test('the PIN is never stored in a readable form', () async {
      await lock.setPin('4821');

      final stored = await db.preferenceDao.read(PreferenceDao.keyPinHash);
      expect(stored, isNotNull);
      expect(stored, isNot(contains('4821')));
      // A salt must exist, or the hash is a lookup away from useless.
      expect(await db.preferenceDao.read(PreferenceDao.keyPinSalt), isNotNull);
    });

    test('replacing the PIN retires the old one', () async {
      await lock.setPin('4821');
      await lock.setPin('1357');

      expect(await lock.verify('1357'), isA<PinAccepted>());
      expect(await lock.verify('4821'), isA<PinRejected>());
    });

    test('disabling removes the credential entirely', () async {
      await lock.setPin('4821');
      await lock.disable();

      expect((await lock.read()).hasPin, isFalse);
      expect(await db.preferenceDao.read(PreferenceDao.keyPinHash), isNull);
      expect(await db.preferenceDao.read(PreferenceDao.keyPinSalt), isNull);
    });

    test('a device with no PIN accepts anything rather than stranding its '
        'owner', () async {
      // A half-written or wiped credential must never become a locked door
      // with no key: nothing here can reset a PIN, so failing closed would
      // mean losing the promises.
      expect(await lock.verify('9999'), isA<PinAccepted>());
    });
  });

  group('failed attempts', () {
    test('a wrong PIN counts down to the cooldown', () async {
      await lock.setPin('4821');

      final first = await lock.verify('0000');
      expect(first, isA<PinRejected>());
      expect(
        (first as PinRejected).attemptsRemaining,
        PreferenceLockRepository.attemptsBeforeCooldown - 1,
      );
    });

    test('five wrong PINs start a cooldown', () async {
      await lock.setPin('4821');
      await failTimes(4);

      expect(await lock.verify('0000'), isA<PinCooldown>());
    });

    test('a cooldown blocks even the correct PIN', () async {
      await lock.setPin('4821');
      await failTimes(5);

      expect(await lock.verify('4821'), isA<PinCooldown>());
    });

    test('waiting out the cooldown costs no extra attempt', () async {
      await lock.setPin('4821');
      await failTimes(5);

      now = now.add(const Duration(minutes: 1));

      expect(await lock.verify('4821'), isA<PinAccepted>());
    });

    test('each round of failures waits longer than the last', () async {
      await lock.setPin('4821');

      await failTimes(4);
      final first = await lock.verify('0000') as PinCooldown;

      now = now.add(first.remaining + const Duration(seconds: 1));
      await failTimes(4);
      final second = await lock.verify('0000') as PinCooldown;

      expect(second.remaining, greaterThan(first.remaining));
    });

    test('the right PIN clears the count', () async {
      await lock.setPin('4821');
      await failTimes(4);
      await lock.verify('4821');

      // Back to a full allowance rather than one attempt from a lockout.
      final next = await lock.verify('0000') as PinRejected;
      expect(
        next.attemptsRemaining,
        PreferenceLockRepository.attemptsBeforeCooldown - 1,
      );
    });
  });

  group('biometrics', () {
    test('are off until asked for, and survive being read back', () async {
      await lock.setPin('4821');
      expect((await lock.read()).biometricEnabled, isFalse);

      await lock.setBiometricEnabled(true);
      expect((await lock.read()).biometricEnabled, isTrue);
    });

    test('are dropped along with the lock', () async {
      await lock.setPin('4821');
      await lock.setBiometricEnabled(true);
      await lock.disable();

      // Otherwise a device that re-enabled a PIN would silently inherit a
      // fingerprint setting its owner never chose this time.
      expect((await lock.read()).biometricEnabled, isFalse);
    });

    test('the lock state is watchable, so the UI never polls', () async {
      expectLater(
        lock.watch().map((settings) => settings.hasPin),
        emitsThrough(isTrue),
      );
      await lock.setPin('4821');
    });
  });
}
