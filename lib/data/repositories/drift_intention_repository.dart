import '../../domain/entities/intention.dart';
import '../../domain/entities/intention_event.dart';
import '../../domain/enums/intention_event_type.dart';
import '../../domain/repositories/intention_repository.dart';
import '../dao/intention_dao.dart';

/// Drift-backed implementation of [IntentionRepository].
///
/// Deliberately thin: the SQL lives in [IntentionDao], the rules live in
/// `domain/usecases`. This class only bridges the two (PRD §5.3).
class DriftIntentionRepository implements IntentionRepository {
  const DriftIntentionRepository(this._dao);

  final IntentionDao _dao;

  @override
  Stream<List<Intention>> watchToday({
    required DateTime dayStart,
    required DateTime dayEnd,
  }) => _dao.watchToday(dayStart, dayEnd);

  @override
  Stream<List<Intention>> watchAllActive() => _dao.watchAllActive();

  @override
  Stream<Intention?> watchById(int id) => _dao.watchById(id);

  @override
  Stream<List<IntentionEvent>> watchEventsSince(DateTime since) =>
      _dao.watchEventsSince(since);

  @override
  Stream<List<IntentionEvent>> watchEventsFor(int intentionId) =>
      _dao.watchEventsFor(intentionId);

  @override
  Stream<Map<IntentionEventType, int>> watchEventCounts() =>
      _dao.watchEventCounts();

  @override
  Stream<List<IntentionEvent>> watchResolutions() => _dao.watchResolutions();

  @override
  Stream<({int links, int conversations})> watchResolvedBreakdown() =>
      _dao.watchResolvedBreakdown();

  @override
  Future<List<Intention>> search(String query) => _dao.search(query);

  @override
  Future<Intention?> findById(int id) => _dao.findById(id);

  @override
  Future<List<Intention>> dueAt(DateTime instant) => _dao.dueAt(instant);

  @override
  Future<Intention?> nextScheduled(DateTime after) => _dao.nextScheduled(after);

  @override
  Future<List<Intention>> missedReminders(
    DateTime now, {
    Duration grace = const Duration(minutes: 10),
  }) => _dao.missedReminders(now, grace: grace);

  @override
  Future<int> count() => _dao.countAll();

  @override
  Future<int> capture(NewIntention intention) => _dao.capture(intention);

  @override
  Future<void> resolve(int id, {required DateTime at}) =>
      _dao.resolve(id, at: at);

  @override
  Future<void> reopen(int id, {required DateTime at}) =>
      _dao.reopen(id, at: at);

  @override
  Future<void> snooze(
    int id, {
    required DateTime until,
    required DateTime at,
  }) => _dao.snooze(id, until: until, at: at);

  @override
  Future<void> archive(int id, {required DateTime at}) =>
      _dao.archive(id, at: at);

  @override
  Future<void> markResurfaced(int id, {required DateTime at, String? tier}) =>
      _dao.markResurfaced(id, at: at, tier: tier);

  @override
  Future<void> updateReminder(
    int id, {
    required DateTime? reminderAt,
    required DateTime at,
  }) => _dao.updateReminder(id, reminderAt, at);

  @override
  Future<void> updateCategory(
    int id, {
    required String? category,
    required DateTime at,
  }) => _dao.updateCategory(id, category, at);

  @override
  Future<void> updateContent(
    int id, {
    required String rawContent,
    required DateTime at,
  }) => _dao.updateContent(id, rawContent, at);

  @override
  Future<List<Intention>> needingEnrichment({int limit = 60}) =>
      _dao.needingEnrichment(limit: limit);

  @override
  Future<void> recordExtractedDeadline(
    int id, {
    required DateTime deadline,
    required DateTime? reminderAt,
    required DateTime at,
  }) => _dao.recordExtractedDeadline(
    id,
    deadline: deadline,
    reminderAt: reminderAt,
    at: at,
  );

  @override
  Future<void> deleteIntention(int id) => _dao.deleteIntention(id);
}
