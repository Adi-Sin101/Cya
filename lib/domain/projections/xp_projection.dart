import '../enums/intention_event_type.dart';
import '../models/user_level.dart';

/// XP, levels and titles — a **projection** over the event log, never a stored
/// counter (PRD §6.6). Recomputing from events makes progress tamper-resistant
/// and repairable: delete the derived value, recompute, get the same answer.
///
/// Weights and curve decided in ADR-002 (PRD §13.3), closing the §13.6 open
/// question. Resolution is worth more than capture on purpose: the product's
/// risk is becoming a second backlog (§12), so the loop must pay better than
/// the hoarding.
abstract final class XpProjection {
  const XpProjection._();

  static const int xpPerCapture = 10;
  static const int xpPerResolution = 25;

  /// XP required to advance *from* [level] to the next one.
  /// `250 × level` — gentle early, meaningful later, and it puts level 12 at
  /// the 3,000 XP band shown in the approved design (§8.2).
  static int xpToAdvance(int level) => 250 * level;

  /// Lifetime XP for a set of event counts.
  static int totalXp(Map<IntentionEventType, int> counts) {
    final captured = counts[IntentionEventType.captured] ?? 0;
    final resolved = counts[IntentionEventType.resolved] ?? 0;
    return captured * xpPerCapture + resolved * xpPerResolution;
  }

  /// Current level plus progress inside it.
  static UserLevel levelFor(int totalXp) {
    var level = 1;
    var remaining = totalXp < 0 ? 0 : totalXp;
    while (remaining >= xpToAdvance(level)) {
      remaining -= xpToAdvance(level);
      level++;
    }
    return UserLevel(
      level: level,
      title: titleFor(level),
      xp: remaining,
      xpTarget: xpToAdvance(level),
    );
  }

  static UserLevel fromEventCounts(Map<IntentionEventType, int> counts) =>
      levelFor(totalXp(counts));

  /// Garden-themed progression titles (the Memory Garden is the emotional core
  /// of retention — the ladder speaks its language).
  static String titleFor(int level) {
    if (level <= 2) return 'Seedling';
    if (level <= 5) return 'Sprout';
    if (level <= 8) return 'Gardener';
    if (level <= 11) return 'Memory Keeper';
    if (level <= 15) return 'Future Builder';
    if (level <= 20) return 'Promise Master';
    return 'Legend';
  }
}
