import '../../domain/entities/intention.dart';
import '../../domain/entities/intention_event.dart';
import '../../domain/enums/intention_event_type.dart';
import '../../domain/enums/intention_status.dart';
import 'cya_database.dart';

/// Row ↔ entity translation. Kept in `data/` so `domain/` never learns that a
/// database exists (PRD §5.3).
extension IntentionRowMapper on IntentionRow {
  Intention toEntity() => Intention(
    id: id,
    sourceApp: sourceApp,
    sourcePackage: sourcePackage,
    rawContent: rawContent,
    snippet: snippet,
    deepLink: deepLink,
    capturedAt: capturedAt,
    reminderAt: reminderAt,
    category: category,
    status: IntentionStatus.fromWire(status),
    snoozeCount: snoozeCount,
    extractedDeadline: extractedDeadline,
    updatedAt: updatedAt,
  );
}

extension IntentionEventRowMapper on IntentionEventRow {
  /// Returns `null` for an event type this build does not know — a row written
  /// by a newer schema. Projections skip it rather than crashing.
  IntentionEvent? toEntity() {
    final eventType = IntentionEventType.tryFromWire(type);
    if (eventType == null) return null;
    return IntentionEvent(
      id: id,
      intentionId: intentionId,
      type: eventType,
      occurredAt: occurredAt,
      metadata: metadata,
    );
  }
}

extension IntentionEventRowsMapper on List<IntentionEventRow> {
  List<IntentionEvent> toEntities() => <IntentionEvent>[
    for (final row in this) ?row.toEntity(),
  ];
}
