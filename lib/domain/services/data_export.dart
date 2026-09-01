import 'dart:convert';

import '../entities/intention.dart';
import '../entities/intention_event.dart';

/// Builds the "take everything with you" document (PRD §9.3).
///
/// Pure Dart with no database and no file system, so the *shape* of what leaves
/// the device is a testable value rather than a side effect. The whole point of
/// a local-first product is that nothing here is a favour the vendor is doing
/// the user: the export is the complete store, in a format anything can read.
///
/// **Secrets never leave.** The PIN's salt and hash are stored in the same
/// preferences table as the theme, and an export that carried them would hand
/// an offline attacker the one thing the KDF exists to protect (ADR-010).
/// [redactedPreferenceKeys] is the filter, and it is a denylist checked in one
/// place rather than a habit each caller has to remember.
abstract final class DataExport {
  const DataExport._();

  /// Bumped whenever the document's shape changes, so an importer — or
  /// `tool/metrics.dart` — can refuse a file it does not understand instead of
  /// silently misreading it.
  static const int formatVersion = 1;

  /// Preference keys withheld from the export.
  ///
  /// Everything to do with the lock: the credential itself, and the
  /// failed-attempt state, which would otherwise let someone reset a cooldown
  /// by re-importing an older file.
  static const Set<String> redactedPreferenceKeys = <String>{
    'lock_pin_salt',
    'lock_pin_hash',
    'lock_pin_iterations',
    'lock_failed_attempts',
    'lock_cooldown_until',
  };

  /// The export as a JSON map.
  static Map<String, Object?> build({
    required DateTime exportedAt,
    required List<Intention> intentions,
    required List<IntentionEvent> events,
    required Map<String, String> preferences,
  }) {
    return <String, Object?>{
      'format': 'cya.export',
      'formatVersion': formatVersion,
      'exportedAt': exportedAt.toIso8601String(),
      // Stated in the file itself, because someone reading this a year from now
      // should not have to take the app's word for where it came from.
      'note':
          'Everything Cya! knows about you. Created on your device; never '
          'uploaded anywhere. Your PIN is deliberately not included.',
      'counts': <String, Object?>{
        'intentions': intentions.length,
        'events': events.length,
      },
      'preferences': <String, Object?>{
        for (final entry in preferences.entries)
          if (!redactedPreferenceKeys.contains(entry.key))
            entry.key: entry.value,
      },
      'intentions': <Object?>[
        for (final intention in intentions) _intention(intention),
      ],
      'events': <Object?>[for (final event in events) _event(event)],
    };
  }

  /// The document as the bytes that get written to a file.
  ///
  /// Indented on purpose: this is a document a person may open in a text
  /// editor, and the few extra kilobytes cost nothing next to being readable.
  static String encode(Map<String, Object?> document) =>
      const JsonEncoder.withIndent('  ').convert(document);

  /// `cya-export-2026-09-01.json` — sorts chronologically in a file list.
  static String fileNameFor(DateTime exportedAt) {
    final month = exportedAt.month.toString().padLeft(2, '0');
    final day = exportedAt.day.toString().padLeft(2, '0');
    return 'cya-export-${exportedAt.year}-$month-$day.json';
  }

  static Map<String, Object?> _intention(Intention intention) =>
      <String, Object?>{
        'id': intention.id,
        'sourceApp': intention.sourceApp,
        'sourcePackage': intention.sourcePackage,
        'rawContent': intention.rawContent,
        'snippet': intention.snippet,
        'deepLink': intention.deepLink,
        'capturedAt': intention.capturedAt.toIso8601String(),
        'reminderAt': intention.reminderAt?.toIso8601String(),
        'category': intention.category,
        'status': intention.status.wire,
        'snoozeCount': intention.snoozeCount,
        'extractedDeadline': intention.extractedDeadline?.toIso8601String(),
        'updatedAt': intention.updatedAt.toIso8601String(),
      };

  static Map<String, Object?> _event(IntentionEvent event) => <String, Object?>{
    'id': event.id,
    'intentionId': event.intentionId,
    'type': event.type.wire,
    'occurredAt': event.occurredAt.toIso8601String(),
    'metadata': event.metadata,
  };
}
