import '../db/cya_database.dart';
import '../../domain/entities/focus_timer.dart';
import 'focus_repository.dart';

const focusTimerKey = 'focus_timer_v1';

/// A projection over the existing focus session, persisted with its event.
class FocusTimerRepository {
  FocusTimerRepository(this.db);
  final CyaDatabase db;
  Future<FocusTimerSnapshot?> load() async {
    final raw = await db.preferenceDao.read(focusTimerKey);
    if (raw == null || raw.isEmpty) return null;
    FocusTimerSnapshot timer;
    try {
      timer = FocusTimerSnapshot.decode(raw);
    } on Object {
      return null;
    }
    final session = await (db.select(
      db.focusSessions,
    )..where((s) => s.id.equals(timer.sessionId))).getSingleOrNull();
    if (session == null ||
        session.endedAt != null ||
        session.priority != timer.priority) {
      return null;
    }
    return timer;
  }

  Future<void> _write(
    FocusTimerSnapshot timer,
    String event,
    DateTime at,
  ) async {
    await db.preferenceDao.write(focusTimerKey, timer.encode());
    await db
        .into(db.focusEvents)
        .insert(
          FocusEventsCompanion.insert(
            sessionId: timer.sessionId,
            type: event,
            occurredAt: at,
          ),
        );
  }

  Future<FocusTimerSnapshot> start(
    String priority,
    int minutes,
    DateTime at, {
    String? occurrenceId,
  }) => db.transaction(() async {
    if (minutes < 1 || minutes > 180 || priority.trim().isEmpty) {
      throw ArgumentError('Choose a priority and duration.');
    }
    if (occurrenceId != null) {
      final occurrence = await (db.select(
        db.routineOccurrences,
      )..where((o) => o.id.equals(occurrenceId))).getSingleOrNull();
      if (occurrence == null) {
        throw StateError('This routine occurrence no longer exists.');
      }
    }
    final previous = await load();
    if (previous != null) await stop(previous.sessionId, at);
    await FocusRepository(db).select(priority, at);
    final session = await (db.select(
      db.focusSessions,
    )..where((s) => s.endedAt.isNull())).getSingle();
    final timer = FocusTimerSnapshot(
      sessionId: session.id,
      priority: session.priority,
      durationSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
      deadline: at.add(Duration(minutes: minutes)),
      occurrenceId: occurrenceId,
    );
    await _write(timer, 'timer_started', at);
    return timer;
  });
  Future<FocusTimerSnapshot> toggle(String expectedSession, DateTime at) =>
      db.transaction(() async {
        final old = await load();
        if (old == null || old.sessionId != expectedSession) {
          throw StateError('Your focus changed. Reopen it.');
        }
        final remaining = old.remainingAt(at);
        if (!old.running && remaining == 0) {
          throw StateError('Choose a new session.');
        }
        final next = FocusTimerSnapshot(
          sessionId: old.sessionId,
          priority: old.priority,
          durationSeconds: old.durationSeconds,
          remainingSeconds: remaining,
          deadline: old.running ? null : at.add(Duration(seconds: remaining)),
          occurrenceId: old.occurrenceId,
        );
        await _write(next, old.running ? 'timer_paused' : 'timer_resumed', at);
        return next;
      });
  Future<void> stop(String expectedSession, DateTime at) =>
      db.transaction(() async {
        final old = await load();
        if (old == null || old.sessionId != expectedSession) {
          throw StateError('Your focus changed. Reopen it.');
        }
        await db
            .into(db.focusEvents)
            .insert(
              FocusEventsCompanion.insert(
                sessionId: old.sessionId,
                type: 'timer_stopped',
                occurredAt: at,
              ),
            );
        await FocusRepository(db).select('', at);
        await db.preferenceDao.remove(focusTimerKey);
      });
}
