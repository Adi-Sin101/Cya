/// Entry kinds in the append-only intention event log (PRD §7.1).
///
/// The log is the backbone of the product: gamification (§6.6) and every V1
/// metric (§11) are *projections* over it, never stored counters. The [wire]
/// value is written by both Dart and the native capture path.
enum IntentionEventType {
  captured('captured'),
  snoozed('snoozed'),
  resurfaced('resurfaced'),
  resolved('resolved'),
  archived('archived'),
  edited('edited');

  const IntentionEventType(this.wire);

  final String wire;

  static IntentionEventType? tryFromWire(String value) {
    for (final type in IntentionEventType.values) {
      if (type.wire == value) return type;
    }
    return null;
  }
}
