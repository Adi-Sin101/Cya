import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dao/intention_dao.dart';
import '../../data/dao/preference_dao.dart';
import '../../data/db/cya_database.dart';
import '../../data/repositories/drift_intention_repository.dart';
import '../../data/seed/demo_seed.dart';
import '../../domain/repositories/intention_repository.dart';
import '../../domain/usecases/capture_intention.dart';
import '../../domain/usecases/manage_intention.dart';
import '../../domain/usecases/resolve_intention.dart';
import '../../domain/usecases/snooze_intention.dart';
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

final captureIntentionProvider = Provider<CaptureIntention>(
  (ref) => CaptureIntention(
    ref.watch(intentionRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final resolveIntentionProvider = Provider<ResolveIntention>(
  (ref) => ResolveIntention(
    ref.watch(intentionRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final snoozeIntentionProvider = Provider<SnoozeIntention>(
  (ref) => SnoozeIntention(
    ref.watch(intentionRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final manageIntentionProvider = Provider<ManageIntention>(
  (ref) => ManageIntention(
    ref.watch(intentionRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final _demoSeedProvider = Provider<DemoSeed>(
  (ref) => DemoSeed(
    ref.watch(intentionDaoProvider),
    ref.watch(preferenceDaoProvider),
  ),
);

/// One-time startup work, kicked off behind the splash so it never blocks the
/// first frame. In release this does nothing: a real first launch starts empty
/// and shows the designed empty state.
final appStartupProvider = FutureProvider<void>((ref) async {
  if (kDebugMode) {
    await ref.watch(_demoSeedProvider).ensureSeeded(ref.watch(clockProvider)());
  }
});
