import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dao/intention_dao.dart';
import '../../data/dao/preference_dao.dart';
import '../../data/db/cya_database.dart';
import '../../data/repositories/drift_intention_repository.dart';
import '../../data/seed/demo_seed.dart';
import '../../domain/repositories/intention_repository.dart';
import '../../domain/services/reminder_scheduler.dart';
import '../../domain/usecases/capture_intention.dart';
import '../../domain/usecases/enrich_intention.dart';
import '../../domain/usecases/manage_intention.dart';
import '../../domain/usecases/resolve_intention.dart';
import '../../domain/usecases/snooze_intention.dart';
import '../../native/platform_reminder_scheduler.dart';
import '../../native/reminder_port.dart';
import '../utils/clock.dart';

/// Infrastructure DI (PRD §5.3 — `core/` owns wiring).
///
/// Screen-level state lives in `presentation/providers`; this file only builds
/// the object graph: database → DAO → repository → use-cases.

/// The one open handle to the local store. Overridden in tests with an
/// in-memory database.
final databaseProvider = Provider<CyaDatabase>((ref) {
  final database = CyaDatabase();
  ref.onDispose(database.close);
  return database;
});

final intentionDaoProvider = Provider<IntentionDao>(
  (ref) => ref.watch(databaseProvider).intentionDao,
);

final preferenceDaoProvider = Provider<PreferenceDao>(
  (ref) => ref.watch(databaseProvider).preferenceDao,
);

final intentionRepositoryProvider = Provider<IntentionRepository>(
  (ref) => DriftIntentionRepository(ref.watch(intentionDaoProvider)),
);

/// Overridable "now" so time-dependent behaviour is testable (see [Clock]).
final clockProvider = Provider<Clock>((ref) => systemClock);

final reminderPortProvider = Provider<ReminderPort>(
  (ref) => const ReminderPort(),
);

/// Reminders are armed by the *native* scheduler — the same one the Share
/// Sheet capture path uses, so both surfaces behave identically (PRD §5.6).
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => PlatformReminderScheduler(ref.watch(reminderPortProvider)),
);

final captureIntentionProvider = Provider<CaptureIntention>(
  (ref) => CaptureIntention(
    ref.watch(intentionRepositoryProvider),
    ref.watch(clockProvider),
    ref.watch(reminderSchedulerProvider),
  ),
);

final resolveIntentionProvider = Provider<ResolveIntention>(
  (ref) => ResolveIntention(
    ref.watch(intentionRepositoryProvider),
    ref.watch(clockProvider),
    ref.watch(reminderSchedulerProvider),
  ),
);

final snoozeIntentionProvider = Provider<SnoozeIntention>(
  (ref) => SnoozeIntention(
    ref.watch(intentionRepositoryProvider),
    ref.watch(clockProvider),
    ref.watch(reminderSchedulerProvider),
  ),
);

final enrichIntentionProvider = Provider<EnrichIntention>(
  (ref) => EnrichIntention(
    ref.watch(intentionRepositoryProvider),
    ref.watch(clockProvider),
    ref.watch(reminderSchedulerProvider),
  ),
);

final manageIntentionProvider = Provider<ManageIntention>(
  (ref) => ManageIntention(
    ref.watch(intentionRepositoryProvider),
    ref.watch(clockProvider),
    ref.watch(reminderSchedulerProvider),
  ),
);

final _demoSeedProvider = Provider<DemoSeed>(
  (ref) => DemoSeed(
    ref.watch(intentionDaoProvider),
    ref.watch(preferenceDaoProvider),
  ),
);

/// One-time startup work, kicked off behind the splash so it never blocks the
/// first frame. In release the seed does nothing: a real first launch starts
/// empty and shows the designed empty state.
final appStartupProvider = FutureProvider<void>((ref) async {
  if (kDebugMode) {
    await ref.watch(_demoSeedProvider).ensureSeeded(ref.watch(clockProvider)());
  }
});

/// Enriches promises that arrived while the app was closed (PRD §5.5).
///
/// Runs *after* startup and never blocks it, because enrichment is by
/// definition not urgent: the promise is already saved and already scheduled.
/// This is the asynchronous half of "capture is dumb and synchronous;
/// enrichment is asynchronous" (§3.2) — and the reason the Share Sheet path
/// can stay at 120ms.
///
/// The rules are pure Dart over a handful of strings and finish in
/// microseconds, so they run inline rather than in an isolate; the work that
/// would justify a `compute()` hop is the database write, which is already
/// async. Revisit if a model ever replaces the rules.
final enrichmentPassProvider = FutureProvider<int>((ref) async {
  await ref.watch(appStartupProvider.future);
  final pending = await ref
      .watch(intentionRepositoryProvider)
      .needingEnrichment();
  if (pending.isEmpty) return 0;
  return ref.watch(enrichIntentionProvider).run(pending);
});
