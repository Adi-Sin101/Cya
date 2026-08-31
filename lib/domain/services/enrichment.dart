/// On-device enrichment of a captured promise (PRD §5.5, §6.5).
///
/// Two jobs, both rule-based and both pure:
///
/// - **Deadline extraction** — find a time the user already wrote down
///   ("tomorrow at 9", "by Friday", "tonight") so the reminder can land when
///   they meant rather than at the zero-tap default.
/// - **Categorization** — guess one of the seven [PromiseCategory] values from
///   the verb and the shape of the content.
///
/// ## Why rules and not a model
///
/// §6.5 permits either. A deterministic parser is testable, needs no model
/// download, runs in microseconds, and — critically — is *auditable*: when it
/// guesses wrong the user can see why. ML Kit remains open for Phase 2+ if
/// these rules prove insufficient; nothing here is on the capture path, so
/// swapping the implementation changes no timings that matter.
///
/// ## Why pure Dart with no Flutter import
///
/// So it can be handed to `compute()` and run in a background isolate without
/// dragging the framework across the boundary (PRD §5.3, §9.1).
///
/// ## The one hard rule
///
/// **Enrichment never runs on the capture path** (PRD §3.2). Capture is one
/// insert and one alarm. This runs afterwards, off the critical path, and
/// never rewrites `rawContent` — it only *adds* a category and a suggested
/// deadline, both of which the user can override.
library;

import '../enums/promise_category.dart';

/// What enrichment found. Every field is optional: finding nothing is the
/// normal case and must cost nothing.
class Enrichment {
  const Enrichment({this.category, this.deadline});

  static const Enrichment none = Enrichment();

  /// The wire value of a [PromiseCategory], or null if no rule matched.
  final String? category;

  /// A deadline the user wrote in the text, resolved against the capture time.
  final DateTime? deadline;

  bool get isEmpty => category == null && deadline == null;
}

/// The enrichment rules (PRD §5.5).
abstract final class EnrichmentService {
  const EnrichmentService._();

  /// Analyses [content] as of [capturedAt].
  ///
  /// [capturedAt] rather than "now" so a promise enriched late still resolves
  /// "tomorrow" against the day it was written, not the day it was processed.
  static Enrichment analyze(String content, DateTime capturedAt) {
    final text = content.toLowerCase();
    if (text.trim().isEmpty) return Enrichment.none;
    return Enrichment(
      category: _categorize(text)?.wire,
      deadline: _extractDeadline(text, capturedAt),
    );
  }

  // --- Categorization -------------------------------------------------------

  /// Keyword rules, most specific first.
  ///
  /// Ordered, not scored: "buy the book" is a *buy*, not a *read*, and the
  /// only reliable way to say that is to let the stronger signal win outright.
  /// A scoring model would need tuning data this product does not have yet.
  static PromiseCategory? _categorize(String text) {
    if (_hasAny(text, _buy)) return PromiseCategory.buy;
    if (_hasAny(text, _reply)) return PromiseCategory.reply;
    if (_hasAny(text, _watch)) return PromiseCategory.watch;
    if (_hasAny(text, _read)) return PromiseCategory.read;
    if (_hasAny(text, _work)) return PromiseCategory.work;
    if (_hasAny(text, _errand)) return PromiseCategory.errand;
    if (_hasAny(text, _idea)) return PromiseCategory.idea;
    // A bare link with no verb is something to look at later.
    if (_url.hasMatch(text)) return PromiseCategory.read;
    return null;
  }

  static const List<String> _buy = <String>[
    'buy',
    'order',
    'purchase',
    'checkout',
    'add to cart',
    'amazon.',
    'price',
    'restock',
  ];
  static const List<String> _reply = <String>[
    'reply',
    'respond',
    'text ',
    'message ',
    'call ',
    'ring ',
    'email ',
    'get back to',
    'follow up with',
    'answer',
  ];
  static const List<String> _watch = <String>[
    'watch',
    'youtube.',
    'youtu.be',
    'netflix',
    'episode',
    'trailer',
    'stream',
  ];
  static const List<String> _read = <String>[
    'read',
    'article',
    'paper',
    'blog',
    'arxiv.',
    'medium.com',
    'newsletter',
    'documentation',
    'docs.',
  ];
  static const List<String> _work = <String>[
    'review',
    'pr #',
    'pull request',
    'deploy',
    'ticket',
    'standup',
    'jira',
    'github.',
    'refactor',
    'merge',
    'spec',
  ];
  static const List<String> _errand = <String>[
    'book ',
    'appointment',
    'dentist',
    'doctor',
    'pick up',
    'drop off',
    'renew',
    'pay ',
    'bill',
    'laundry',
    'groceries',
  ];
  static const List<String> _idea = <String>[
    'idea',
    'what if',
    'maybe we',
    'concept',
    'brainstorm',
    'think about',
  ];

  static final RegExp _url = RegExp(r'https?://\S+');

  static bool _hasAny(String text, List<String> needles) {
    for (final needle in needles) {
      if (text.contains(needle)) return true;
    }
    return false;
  }

  // --- Deadline extraction --------------------------------------------------

  /// Named days and times the user might have written.
  ///
  /// Deliberately conservative. A wrong deadline is worse than no deadline:
  /// it moves a reminder the user never asked to move. Anything ambiguous
  /// returns null and the zero-tap default stands.
  static DateTime? _extractDeadline(String text, DateTime from) {
    // "at 7pm", "at 19:00", "by 9 am" — a clock time to apply to whatever day
    // the rest of the phrase resolves to.
    final time = _extractTimeOfDay(text);

    // An hour with no am/pm attached to a named day: 1–7 reads as afternoon
    // ("on Friday at 3" is not 3am), 8–12 as morning.
    int settled(int hour) =>
        !time!.explicit && hour >= 1 && hour <= 7 ? hour + 12 : hour;

    DateTime at(DateTime day, {int fallbackHour = 9}) => DateTime(
      day.year,
      day.month,
      day.day,
      time == null ? fallbackHour : settled(time.hour),
      time?.minute ?? 0,
    );

    if (text.contains('tonight') || text.contains('this evening')) {
      return at(from, fallbackHour: 20);
    }
    if (text.contains('tomorrow')) {
      return at(DateTime(from.year, from.month, from.day + 1));
    }
    if (text.contains('this weekend') || text.contains('weekend')) {
      return at(_nextWeekday(from, DateTime.saturday), fallbackHour: 10);
    }
    if (text.contains('next week')) {
      return at(_nextWeekday(from, DateTime.monday), fallbackHour: 9);
    }

    for (final entry in _weekdays.entries) {
      // Word-bounded so "sun" does not match "sunscreen" and "sat" does not
      // match "satisfied".
      if (RegExp('\\b${entry.key}\\b').hasMatch(text)) {
        return at(_nextWeekday(from, entry.value));
      }
    }

    // A bare time with no day: the soonest reading that is still ahead.
    //
    // With no am/pm this deliberately considers *both* readings and takes the
    // next one to arrive — "call her at 8", written at half three, means eight
    // tonight, and a rule that fixed 8 to the morning would quietly move the
    // reminder sixteen hours later than the user meant.
    if (time != null) {
      final candidates = <DateTime>[
        DateTime(from.year, from.month, from.day, time.hour, time.minute),
        if (!time.explicit && time.hour < 12)
          DateTime(
            from.year,
            from.month,
            from.day,
            time.hour + 12,
            time.minute,
          ),
      ]..sort();

      for (final candidate in candidates) {
        if (candidate.isAfter(from)) return candidate;
      }
      // Every reading has already gone by today, so it is tomorrow's.
      return DateTime(
        from.year,
        from.month,
        from.day + 1,
        settled(time.hour),
        time.minute,
      );
    }
    return null;
  }

  static const Map<String, int> _weekdays = <String, int>{
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };

  /// `at 7pm`, `by 7:30 pm`, `at 19:00`.
  static final RegExp _timePattern = RegExp(
    r'\b(?:at|by|before|around)\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b',
  );

  /// The written clock time, and whether the user said am/pm.
  ///
  /// [explicit] is carried rather than resolved here, because what an
  /// ambiguous "8" means depends on whether a day was named alongside it —
  /// which only the caller knows.
  static ({int hour, int minute, bool explicit})? _extractTimeOfDay(
    String text,
  ) {
    final match = _timePattern.firstMatch(text);
    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.tryParse(match.group(2) ?? '') ?? 0;
    final meridiem = match.group(3);

    if (meridiem == 'pm' && hour < 12) hour += 12;
    if (meridiem == 'am' && hour == 12) hour = 0;

    if (hour > 23 || minute > 59) return null;
    // A 24-hour time is unambiguous even without a meridiem.
    return (
      hour: hour,
      minute: minute,
      explicit: meridiem != null || hour > 12,
    );
  }

  /// The next [weekday] strictly after [from]; today does not count, because
  /// "on Friday" written on a Friday means the coming one.
  static DateTime _nextWeekday(DateTime from, int weekday) {
    var days = (weekday - from.weekday) % 7;
    if (days == 0) days = 7;
    return DateTime(from.year, from.month, from.day + days);
  }
}
