import '../enums/intention_event_type.dart';

/// One immutable entry in the append-only intention log (PRD §7.1).
///
/// Nothing ever updates or deletes an event. Every projection in the app — XP,
/// levels, the Memory Garden, weekly stats, §11 metrics — is derived from these
/// rows, which is what makes them recomputable and tamper-resistant (§6.6).
class IntentionEvent {
  const IntentionEvent({
    required this.id,
    required this.intentionId,
    required this.type,
    required this.occurredAt,
    this.metadata,
  });

  final int id;
  final int intentionId;
  final IntentionEventType type;
  final DateTime occurredAt;

  /// Free-form JSON payload (e.g. the snooze target, the escalation tier).
  final String? metadata;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntentionEvent &&
          other.id == id &&
          other.intentionId == intentionId &&
          other.type == type &&
          other.occurredAt == occurredAt &&
          other.metadata == metadata;

  @override
  int get hashCode => Object.hash(id, intentionId, type, occurredAt, metadata);
}
