import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_home_repository.dart';
import '../../domain/models/home_summary.dart';
import '../../domain/models/promise.dart';

/// DI seam for the Home data source. Swapped for the Drift repository later.
final mockHomeRepositoryProvider = Provider<MockHomeRepository>(
  (ref) => const MockHomeRepository(),
);

/// Holds the reactive Home state. Toggling a promise updates both the list and
/// the Today completion ring — demonstrating the reactive-over-store pattern
/// (PRD §3.3) that the real Drift-backed store will fulfil.
class HomeController extends Notifier<HomeSummary> {
  @override
  HomeSummary build() =>
      ref.watch(mockHomeRepositoryProvider).loadHomeSummary();

  void togglePromise(String id) {
    state = state.copyWith(
      promises: <Promise>[
        for (final promise in state.promises)
          if (promise.id == id)
            promise.copyWith(isCompleted: !promise.isCompleted)
          else
            promise,
      ],
    );
  }
}

final homeControllerProvider = NotifierProvider<HomeController, HomeSummary>(
  HomeController.new,
);
