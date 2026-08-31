/// Lifecycle state of an intention (PRD §7.1).
///
/// The [wire] value is the exact string stored in the `intentions.status`
/// column. The native capture path writes these literals directly, so they are
/// part of the cross-runtime contract (see `docs/native_db_contract.md`) and
/// must never be renamed without a schema migration on both sides.
enum IntentionStatus {
  open('open'),
  snoozed('snoozed'),
  resolved('resolved'),
  archived('archived');

  const IntentionStatus(this.wire);

  final String wire;

  static IntentionStatus fromWire(String value) {
    for (final status in IntentionStatus.values) {
      if (status.wire == value) return status;
    }
    // Unknown values can only come from a newer schema; treat as open rather
    // than losing the row (PRD §3.3 — the store is the source of truth).
    return IntentionStatus.open;
  }

  /// Whether the promise still awaits action from the user.
  bool get isPending =>
      this == IntentionStatus.open || this == IntentionStatus.snoozed;
}
