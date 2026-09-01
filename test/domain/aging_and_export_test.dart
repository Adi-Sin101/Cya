// Retirement (ADR-014) and the data export (PRD §9.3) — the two policies that
// decide what leaves the store and what quietly stops being a promise.

import 'package:cya/domain/entities/intention.dart';
import 'package:cya/domain/entities/intention_event.dart';
import 'package:cya/domain/enums/intention_event_type.dart';
import 'package:cya/domain/enums/intention_status.dart';
import 'package:cya/domain/policies/aging_policy.dart';
import 'package:cya/domain/services/data_export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 1, 20, 30);

  Intention promise({
    int id = 1,
    IntentionStatus status = IntentionStatus.open,
    Duration untouchedFor = Duration.zero,
  }) {
    return Intention(
      id: id,
      sourceApp: 'Messenger',
      rawContent: 'Reply to Sarah',
      capturedAt: now.subtract(const Duration(days: 90)),
      updatedAt: now.subtract(untouchedFor),
      status: status,
    );
  }

  group('AgingPolicy (ADR-014)', () {
    test('a promise touched inside the window stays', () {
      expect(
        AgingPolicy.hasAgedOut(
          promise(untouchedFor: const Duration(days: 29, hours: 23)),
          now,
        ),
        isFalse,
      );
    });

    test('a promise untouched for the full window ages out', () {
      expect(
        AgingPolicy.hasAgedOut(promise(untouchedFor: const Duration(days: 30)), now),
        isTrue,
      );
    });

    test('measures from updatedAt, not capturedAt', () {
      // Captured 90 days ago but snoozed yesterday: the user is clearly still
      // engaged with it, and retiring it would delete a live decision.
      expect(
        AgingPolicy.hasAgedOut(
          promise(
            status: IntentionStatus.snoozed,
            untouchedFor: const Duration(days: 1),
          ),
          now,
        ),
        isFalse,
      );
    });

    test('only pending promises age out', () {
      for (final status in <IntentionStatus>[
        IntentionStatus.resolved,
        IntentionStatus.archived,
      ]) {
        expect(
          AgingPolicy.hasAgedOut(
            promise(status: status, untouchedFor: const Duration(days: 400)),
            now,
          ),
          isFalse,
          reason: '$status is already closed; retiring it would be a lie',
        );
      }
    });

    test('the cutoff matches the predicate', () {
      // The data layer filters by cutoff rather than evaluating the predicate
      // per row, so the two must not be allowed to drift apart.
      final cutoff = AgingPolicy.cutoffFrom(now);
      expect(now.difference(cutoff), AgingPolicy.retirementAge);
    });
  });

  group('DataExport (§9.3)', () {
    Map<String, Object?> build({Map<String, String>? preferences}) {
      return DataExport.build(
        exportedAt: now,
        intentions: <Intention>[promise()],
        events: <IntentionEvent>[
          IntentionEvent(
            id: 1,
            intentionId: 1,
            type: IntentionEventType.captured,
            occurredAt: now,
            metadata: '{"capture_ms":12}',
          ),
        ],
        preferences: preferences ?? const <String, String>{},
      );
    }

    test('never carries the PIN off the device', () {
      // The whole point of the KDF is that this hash is expensive to attack.
      // Exporting it hands an attacker the one artefact worth attacking, in a
      // file the user is encouraged to email to themselves.
      final document = build(
        preferences: const <String, String>{
          'display_name': 'Arif',
          'lock_pin_hash': 'SECRET-HASH',
          'lock_pin_salt': 'SECRET-SALT',
          'lock_pin_iterations': '100000',
          'lock_failed_attempts': '3',
          'lock_cooldown_until': '2026-09-01T20:00:00.000',
        },
      );

      final preferences = document['preferences']! as Map<String, Object?>;
      expect(preferences['display_name'], 'Arif');
      for (final redacted in DataExport.redactedPreferenceKeys) {
        expect(preferences.containsKey(redacted), isFalse, reason: redacted);
      }
      expect(DataExport.encode(document), isNot(contains('SECRET')));
    });

    test('carries every promise and every event', () {
      final document = build();
      expect((document['intentions']! as List<Object?>), hasLength(1));
      expect((document['events']! as List<Object?>), hasLength(1));
      expect(
        (document['counts']! as Map<String, Object?>)['intentions'],
        1,
      );
    });

    test('is self-describing, so a reader can refuse a shape it cannot read', () {
      final document = build();
      expect(document['format'], 'cya.export');
      expect(document['formatVersion'], DataExport.formatVersion);
      expect(document['exportedAt'], now.toIso8601String());
    });

    test('encodes to valid, re-readable JSON', () {
      final encoded = DataExport.encode(build());
      expect(encoded, contains('"rawContent": "Reply to Sarah"'));
      // Indented on purpose — this is a document a person may open.
      expect(encoded, contains('\n  '));
    });

    test('the file name sorts chronologically', () {
      expect(
        DataExport.fileNameFor(DateTime(2026, 3, 4)),
        'cya-export-2026-03-04.json',
      );
    });
  });
}
