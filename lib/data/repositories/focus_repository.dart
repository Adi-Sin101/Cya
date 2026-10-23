import 'package:drift/drift.dart';
import '../../core/utils/local_id.dart';
import '../db/cya_database.dart';

const focusPriorityKey = 'focus_priority';

class FocusRepository {
  FocusRepository(this.db);
  final CyaDatabase db;

  /// The current preference remains a projection, never the historic record.
  Future<void> select(String priority, DateTime at) => db.transaction(() async {
    final value = priority.trim();
    if (value.length > 500) {
      throw ArgumentError('Keep your priority within500 characters.');
    }
    final active = await (db.select(
      db.focusSessions,
    )..where((s) => s.endedAt.isNull())).get();
    if (active.length == 1 && active.single.priority == value) return;
    for (final session in active) {
      final end = at.isBefore(session.startedAt) ? session.startedAt : at;
      await (db.update(db.focusSessions)..where((s) => s.id.equals(session.id)))
          .write(FocusSessionsCompanion(endedAt: Value(end)));
      await db
          .into(db.focusEvents)
          .insert(
            FocusEventsCompanion.insert(
              sessionId: session.id,
              type: 'ended',
              occurredAt: end,
            ),
          );
    }
    if (value.isNotEmpty) {
      final id = newLocalId();
      await db
          .into(db.focusSessions)
          .insert(FocusSessionRow(id: id, priority: value, startedAt: at));
      await db
          .into(db.focusEvents)
          .insert(
            FocusEventsCompanion.insert(
              sessionId: id,
              type: 'started',
              occurredAt: at,
            ),
          );
    }
    await db.preferenceDao.write(focusPriorityKey, value);
  });
  Stream<List<FocusSessionRow>> history() => (db.select(
    db.focusSessions,
  )..orderBy([(s) => OrderingTerm.desc(s.startedAt)])).watch();
}
