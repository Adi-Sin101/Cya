import '../entities/intention.dart';

/// When a promise nobody has touched stops being a promise (ADR-014).
///
/// Nothing in the store expired before this, so the pending list only ever
/// grew, and the weekly digest read a lengthening backlog back at the user
/// every Sunday — §12's failure mode arriving by design rather than by
/// accident. A memory product that accumulates is a to-do list, which is the
/// one thing Cya! is not (§1.2).
///
/// The retirement is deliberately *quiet and reversible*: an aged-out promise
/// is archived, announced once in the digest, and restorable with one tap. It
/// is never deleted — the event log is append-only, and "I decided this no
/// longer matters" is a decision the user gets to disagree with.
abstract final class AgingPolicy {
  const AgingPolicy._();

  /// How long a pending promise may sit untouched before it retires.
  ///
  /// Thirty days, not seven: the §2.2 user genuinely saves things to read "at
  /// some point", and a fortnight-old article is still a fair thing to keep.
  /// A month with no reminder fired, no snooze, no edit and no glance is not
  /// procrastination — it is a decision that was never going to be made.
  static const Duration retirementAge = Duration(days: 30);

  /// Written into the `archived` event's metadata so the log can always tell an
  /// automatic retirement from one the user chose. The digest's "quietly
  /// retired" section reads exactly this.
  static const String reason = 'aged_out';

  /// The `updatedAt` on or before which a pending promise has aged out.
  ///
  /// Expressed as a cutoff rather than a per-row predicate so the data layer
  /// can do this in one indexed query instead of loading the table.
  static DateTime cutoffFrom(DateTime now) => now.subtract(retirementAge);

  /// Whether [intention] has aged out as of [now].
  ///
  /// Keyed on `updatedAt`, not `capturedAt`: a snooze, an edit or a fired
  /// reminder all touch it, so anything the user or the scheduler has been
  /// near recently is safe. A promise only ages out if genuinely *nothing*
  /// has happened to it.
  static bool hasAgedOut(Intention intention, DateTime now) =>
      intention.status.isPending &&
      !intention.updatedAt.isAfter(cutoffFrom(now));
}
