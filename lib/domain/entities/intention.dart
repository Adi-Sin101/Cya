import '../enums/intention_status.dart';

/// A captured intention — the product's core object, surfaced to users as a
/// **promise** (PRD §1.4, §7.1).
///
/// Current-state row. Every transition that produced it is recorded in the
/// append-only event log ([IntentionEvent]); this entity is a convenience
/// snapshot, never the record of truth for metrics.
class Intention {
  const Intention({
    required this.id,
    required this.sourceApp,
    required this.rawContent,
    required this.capturedAt,
    required this.updatedAt,
    this.snippet,
    this.deepLink,
    this.reminderAt,
    this.category,
    this.status = IntentionStatus.open,
    this.snoozeCount = 0,
    this.extractedDeadline,
  });

  final int id;

  /// Where the intention came from, e.g. `Messenger`, `Chrome`, `Cya!`.
  final String sourceApp;

  /// Exactly what was captured — never rewritten by enrichment (PRD §3.2).
  final String rawContent;

  /// Short display form of the captured context, when one is available.
  final String? snippet;

  /// Return-to-source deep link (PRD §6.3).
  final String? deepLink;

  final DateTime capturedAt;
  final DateTime? reminderAt;
  final String? category;
  final IntentionStatus status;
  final int snoozeCount;

  /// Deadline found by on-device enrichment (PRD §5.5), not by the user.
  final DateTime? extractedDeadline;

  final DateTime updatedAt;

  bool get isResolved => status == IntentionStatus.resolved;

  /// One-line display title: the first line of the captured content, trimmed.
  /// Presentation never invents a title — it shows what the user captured.
  String get title {
    final firstLine = rawContent.trim().split('\n').first.trim();
    return firstLine.isEmpty ? 'Untitled promise' : firstLine;
  }

  Intention copyWith({
    String? sourceApp,
    String? rawContent,
    String? snippet,
    String? deepLink,
    DateTime? reminderAt,
    String? category,
    IntentionStatus? status,
    int? snoozeCount,
    DateTime? extractedDeadline,
    DateTime? updatedAt,
  }) {
    return Intention(
      id: id,
      sourceApp: sourceApp ?? this.sourceApp,
      rawContent: rawContent ?? this.rawContent,
      snippet: snippet ?? this.snippet,
      deepLink: deepLink ?? this.deepLink,
      capturedAt: capturedAt,
      reminderAt: reminderAt ?? this.reminderAt,
      category: category ?? this.category,
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      extractedDeadline: extractedDeadline ?? this.extractedDeadline,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Intention &&
          other.id == id &&
          other.sourceApp == sourceApp &&
          other.rawContent == rawContent &&
          other.snippet == snippet &&
          other.deepLink == deepLink &&
          other.capturedAt == capturedAt &&
          other.reminderAt == reminderAt &&
          other.category == category &&
          other.status == status &&
          other.snoozeCount == snoozeCount &&
          other.extractedDeadline == extractedDeadline &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    sourceApp,
    rawContent,
    snippet,
    deepLink,
    capturedAt,
    reminderAt,
    category,
    status,
    snoozeCount,
    extractedDeadline,
    updatedAt,
  );
}

/// A capture that has not been written to the store yet.
///
/// Deliberately minimal: the capture path does one insert and nothing else
/// (PRD §3.2). Category and deadline are filled in later by enrichment.
class NewIntention {
  const NewIntention({
    required this.sourceApp,
    required this.rawContent,
    required this.capturedAt,
    required this.reminderAt,
    this.snippet,
    this.deepLink,
  });

  final String sourceApp;
  final String rawContent;
  final String? snippet;
  final String? deepLink;
  final DateTime capturedAt;
  final DateTime? reminderAt;
}
