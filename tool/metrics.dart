// Reads a Cya! data export and prints the numbers PRD §11 asks for.
//
// Usage:
//   1. In the app: Profile → Privacy → Export my data, and save the JSON.
//   2. dart run tool/metrics.dart path/to/cya-export-2026-09-01.json
//
// It reads the **export**, not the database file, on purpose. The store is
// encrypted at rest, so a script that opened it would need the device key and
// would only ever work on the machine that made it; the export is plaintext,
// portable, and already the format the user is entitled to. It is also the
// format this script cannot silently drift from — if the export loses a field,
// this stops working loudly.
//
// Nothing here talks to a network. It is a reading tool, not telemetry: PRD
// §3.5 means these numbers only exist where the user put them.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty || args.first == '-h' || args.first == '--help') {
    stdout.writeln(_usage);
    exit(args.isEmpty ? 64 : 0);
  }

  final file = File(args.first);
  if (!file.existsSync()) {
    stderr.writeln('No such file: ${args.first}');
    exit(66);
  }

  final Map<String, Object?> document;
  try {
    document = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  } on Object catch (error) {
    stderr.writeln('Not a readable JSON export: $error');
    exit(65);
  }

  if (document['format'] != 'cya.export') {
    stderr.writeln('Not a Cya! export (missing "format": "cya.export").');
    exit(65);
  }
  // Refuse a shape this script was not written against rather than misreading
  // it — a metric that is quietly wrong is worse than one that is missing.
  final version = document['formatVersion'];
  if (version != 1) {
    stderr.writeln(
      'Export format v$version, but this script understands v1. '
      'Update tool/metrics.dart.',
    );
    exit(65);
  }

  final intentions = _rows(document['intentions']);
  final events = _rows(document['events']);
  if (intentions.isEmpty) {
    stdout.writeln('The export is empty — nothing captured yet.');
    return;
  }

  final report = _Report(intentions: intentions, events: events);
  stdout.writeln(report.render(exportedAt: document['exportedAt'] as String?));
}

const String _usage = '''
Cya! metrics — the §11 numbers, read from a data export.

  dart run tool/metrics.dart <cya-export-YYYY-MM-DD.json>

Get the file from the app: Profile → Privacy → Export my data.
''';

List<Map<String, Object?>> _rows(Object? value) => <Map<String, Object?>>[
  for (final row in (value as List<Object?>? ?? const <Object?>[]))
    row as Map<String, Object?>,
];

class _Report {
  _Report({required this.intentions, required this.events});

  final List<Map<String, Object?>> intentions;
  final List<Map<String, Object?>> events;

  String render({String? exportedAt}) {
    final buffer = StringBuffer()
      ..writeln('Cya! — metrics')
      ..writeln('=' * 52);
    if (exportedAt != null) buffer.writeln('Export taken   $exportedAt');
    buffer
      ..writeln('Promises       ${intentions.length}')
      ..writeln('Events         ${events.length}')
      ..writeln();

    _captureRate(buffer);
    _resolution(buffer);
    _latency(buffer);
    _snoozes(buffer);
    _retirements(buffer);
    _missedAlarms(buffer);
    _captureSpeed(buffer);
    return buffer.toString();
  }

  // --- §11: are people capturing? ---
  void _captureRate(StringBuffer out) {
    final days = <String, int>{};
    for (final intention in intentions) {
      final at = _date(intention['capturedAt']);
      if (at == null) continue;
      days.update(_dayKey(at), (n) => n + 1, ifAbsent: () => 1);
    }
    if (days.isEmpty) return;
    final total = days.values.fold(0, (a, b) => a + b);
    final busiest = days.entries.reduce((a, b) => a.value >= b.value ? a : b);

    out
      ..writeln('CAPTURE')
      ..writeln('  Active days          ${days.length}')
      ..writeln(
        '  Captures/active day  ${(total / days.length).toStringAsFixed(2)}',
      )
      ..writeln('  Busiest day          ${busiest.key} (${busiest.value})')
      ..writeln();
  }

  // --- §11: are promises being kept? ---
  void _resolution(StringBuffer out) {
    final byStatus = <String, int>{};
    for (final intention in intentions) {
      final status = intention['status'] as String? ?? 'open';
      byStatus.update(status, (n) => n + 1, ifAbsent: () => 1);
    }
    final resolved = byStatus['resolved'] ?? 0;
    out.writeln('RESOLUTION');
    for (final entry in byStatus.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))) {
      out.writeln('  ${entry.key.padRight(20)} ${entry.value}');
    }
    out
      ..writeln(
        '  Kept-rate            '
        '${_percent(resolved, intentions.length)} '
        '($resolved of ${intentions.length})',
      )
      ..writeln();
  }

  /// Resurface → resolve: how long a promise sits after Cya! brings it back.
  ///
  /// The number the product lives or dies by. Capture speed is a latency
  /// budget; *this* is whether resurfacing at the right moment actually works.
  void _latency(StringBuffer out) {
    final firstResurface = <int, DateTime>{};
    final resolved = <int, DateTime>{};
    for (final event in events) {
      final id = event['intentionId'] as int?;
      final at = _date(event['occurredAt']);
      if (id == null || at == null) continue;
      switch (event['type']) {
        case 'resurfaced':
          firstResurface.putIfAbsent(id, () => at);
        case 'resolved':
          resolved.putIfAbsent(id, () => at);
      }
    }

    final gaps = <Duration>[
      for (final entry in firstResurface.entries)
        if (resolved[entry.key] case final DateTime done)
          if (!done.isBefore(entry.value)) done.difference(entry.value),
    ]..sort();

    out.writeln('RESURFACE → RESOLVE');
    if (gaps.isEmpty) {
      out
        ..writeln('  No promise has been both shown and kept yet.')
        ..writeln();
      return;
    }
    out
      ..writeln('  Samples              ${gaps.length}')
      ..writeln('  Median               ${_duration(gaps[gaps.length ~/ 2])}')
      ..writeln('  p90                  '
          '${_duration(gaps[((gaps.length - 1) * 0.9).round()])}')
      ..writeln('  Within the hour      '
          '${_percent(gaps.where((g) => g.inMinutes <= 60).length, gaps.length)}')
      ..writeln();
  }

  // --- §5.6: is the escalation ladder doing its job? ---
  void _snoozes(StringBuffer out) {
    final histogram = <int, int>{};
    for (final intention in intentions) {
      final count = intention['snoozeCount'] as int? ?? 0;
      histogram.update(count, (n) => n + 1, ifAbsent: () => 1);
    }
    final atLimit = intentions
        .where((i) => (i['snoozeCount'] as int? ?? 0) >= 3)
        .length;

    out.writeln('SNOOZES');
    for (final key in histogram.keys.toList()..sort()) {
      final label = key == 0 ? 'never' : '$key×';
      out.writeln(
        '  ${label.padRight(20)} ${histogram[key]}'
        '${key >= 3 ? '   ← at the limit' : ''}',
      );
    }
    out
      ..writeln(
        '  Reached the limit    ${_percent(atLimit, intentions.length)}',
      )
      ..writeln();
  }

  // --- ADR-014: is the backlog actually shrinking? ---
  void _retirements(StringBuffer out) {
    var aged = 0;
    var byHand = 0;
    for (final event in events) {
      if (event['type'] != 'archived') continue;
      final metadata = event['metadata'] as String? ?? '';
      if (metadata.contains('"reason":"aged_out"')) {
        aged++;
      } else {
        byHand++;
      }
    }
    out
      ..writeln('RETIREMENT')
      ..writeln('  Aged out (30 days)   $aged')
      ..writeln('  Let go by hand       $byHand')
      ..writeln();
  }

  /// §12's nightmare, measured: a reminder time that came and went with no
  /// `resurfaced` event is an alarm the OS silently dropped.
  void _missedAlarms(StringBuffer out) {
    final resurfacedIds = <int>{
      for (final event in events)
        if (event['type'] == 'resurfaced') event['intentionId'] as int,
    };

    var due = 0;
    var missed = 0;
    final now = DateTime.now();
    for (final intention in intentions) {
      final status = intention['status'] as String? ?? 'open';
      final reminderAt = _date(intention['reminderAt']);
      if (reminderAt == null || reminderAt.isAfter(now)) continue;
      if (status != 'open' && status != 'snoozed') continue;
      due++;
      if (!resurfacedIds.contains(intention['id'])) missed++;
    }

    out.writeln('ALARM RELIABILITY');
    if (due == 0) {
      out
        ..writeln('  Nothing pending is past its reminder time.')
        ..writeln();
      return;
    }
    out
      ..writeln('  Past due              $due')
      ..writeln('  Never shown           $missed  ${_percent(missed, due)}')
      ..writeln(
        missed == 0
            ? '  Every due reminder was delivered.'
            : '  ⚠ These are alarms the OS dropped — check Autostart and '
                  'battery settings on this device (PRD §12).',
      )
      ..writeln();
  }

  /// §9.2's hard budget: tap → saved in under 2s, aiming under 1s. Written
  /// into the `captured` event by both runtimes, so this measures the real
  /// native path and not a stopwatch in a test.
  void _captureSpeed(StringBuffer out) {
    final samples = <int>[];
    for (final event in events) {
      if (event['type'] != 'captured') continue;
      final metadata = event['metadata'] as String? ?? '';
      final match = RegExp(r'"capture_ms"\s*:\s*(\d+)').firstMatch(metadata);
      if (match != null) samples.add(int.parse(match.group(1)!));
    }
    if (samples.isEmpty) return;
    samples.sort();

    final overBudget = samples.where((ms) => ms > 2000).length;
    out
      ..writeln('CAPTURE SPEED (native path)')
      ..writeln('  Samples              ${samples.length}')
      ..writeln('  Median               ${samples[samples.length ~/ 2]} ms')
      ..writeln(
        '  p90                  '
        '${samples[((samples.length - 1) * 0.9).round()]} ms',
      )
      ..writeln('  Slowest              ${samples.last} ms')
      ..writeln(
        '  Over the 2s budget   $overBudget'
        '${overBudget == 0 ? '  ✓' : '  ← §9.2 violation'}',
      )
      ..writeln();
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  static String _dayKey(DateTime at) =>
      '${at.year}-${at.month.toString().padLeft(2, '0')}'
      '-${at.day.toString().padLeft(2, '0')}';

  static String _percent(int part, int whole) =>
      whole == 0 ? '—' : '${(part * 100 / whole).toStringAsFixed(1)}%';

  static String _duration(Duration d) {
    if (d.inMinutes < 1) return '${d.inSeconds}s';
    if (d.inHours < 1) return '${d.inMinutes}m';
    if (d.inDays < 1) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inDays}d ${d.inHours % 24}h';
  }
}
