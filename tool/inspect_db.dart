// Inspects a `cya.db` pulled off a device, to verify what the *native* capture
// path actually wrote (PRD §5.4, docs/native_db_contract.md).
//
//   adb exec-out run-as com.example.cya cat files/cya.db > pulled.db
//   dart run tool/inspect_db.dart pulled.db
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run tool/inspect_db.dart <path-to-cya.db>');
    exitCode = 64;
    return;
  }
  final db = sqlite3.open(args.first, mode: OpenMode.readOnly);
  try {
    final version = db.select('PRAGMA user_version').first.values.first;
    stdout.writeln('user_version: $version');

    final tables = db.select(
      "SELECT name FROM sqlite_master WHERE type IN ('table','trigger','index') "
      'ORDER BY name',
    );
    stdout.writeln('objects: ${tables.map((r) => r['name']).join(', ')}');

    stdout.writeln('\nintentions:');
    for (final row in db.select('SELECT * FROM intentions ORDER BY id')) {
      final captured = _at(row['captured_at']);
      final reminder = _at(row['reminder_at']);
      stdout.writeln(
        '  #${row['id']} [${row['status']}] ${row['source_app']} :: '
        '${row['raw_content']}\n'
        '      captured $captured  reminder $reminder  '
        'deep_link=${row['deep_link']}',
      );
    }

    stdout.writeln('\nintention_events:');
    for (final row in db.select('SELECT * FROM intention_events ORDER BY id')) {
      stdout.writeln(
        '  #${row['id']} intention=${row['intention_id']} ${row['type']} '
        '@ ${_at(row['occurred_at'])}  ${row['metadata'] ?? ''}',
      );
    }

    stdout.writeln('\nFTS probe (match "later"):');
    final hits = db.select(
      'SELECT i.id, i.raw_content FROM intentions_fts f '
      'JOIN intentions i ON i.id = f.rowid WHERE intentions_fts MATCH ?',
      <Object?>['"later"*'],
    );
    for (final row in hits) {
      stdout.writeln('  #${row['id']} ${row['raw_content']}');
    }
    if (hits.isEmpty) stdout.writeln('  (no hits)');
  } finally {
    db.close();
  }
}

String _at(Object? seconds) {
  if (seconds == null) return 'null';
  final value = seconds as int;
  return DateTime.fromMillisecondsSinceEpoch(value * 1000).toString();
}
