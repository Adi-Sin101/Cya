import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/settings_providers.dart';
import '../../presentation/screens/achievements/achievements_screen.dart';
import '../../presentation/screens/digest/digest_screen.dart';
import '../../presentation/screens/garden/garden_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/onboarding/lock_setup_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/onboarding/profile_setup_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/promise_detail/promise_detail_screen.dart';
import '../../presentation/screens/promises/promises_screen.dart';
import '../../presentation/shell/home_shell.dart';
import 'route_paths.dart';

/// The app's [GoRouter], exposed through Riverpod for DI.
///
/// A [StatefulShellRoute.indexedStack] gives each bottom-nav tab its own
/// navigator + preserved state. The center capture (+) is a docked FAB, not a
/// branch (see [HomeShell]).
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.home,
    // A fresh install is sent through onboarding before it can reach anything
    // else — the share gesture is the product, and nothing else teaches it
    // (iteration 9, work item 1).
    //
    // The redirect only fires once the store has *answered*: while the flag is
    // still loading it returns null, so a returning user is never bounced
    // through a welcome screen because disk was a frame slow. The splash covers
    // that window (see `CyaBootstrap`).
    redirect: (context, state) {
      final complete = ref.read(onboardingCompleteProvider).valueOrNull;
      if (complete == null) return null;
      final inFlow = state.matchedLocation.startsWith(RoutePaths.onboarding);
      if (!complete && !inFlow) return RoutePaths.onboarding;
      if (complete && inFlow) return RoutePaths.home;
      return null;
    },
    // `redirect` reads the flag rather than watching it, so the router is told
    // explicitly when it changes — otherwise finishing setup would leave the
    // user on the last slide.
    refreshListenable: _OnboardingSignal(ref),
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileSetupScreen(),
          ),
          GoRoute(
            path: 'lock',
            builder: (context, state) => const LockSetupScreen(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.promises,
                builder: (context, state) => const PromisesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.garden,
                builder: (context, state) => const GardenScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.lockSettings,
        builder: (context, state) =>
            const LockSetupScreen(isOnboarding: false),
      ),
      GoRoute(
        path: RoutePaths.digest,
        builder: (context, state) => const DigestScreen(),
      ),
      GoRoute(
        path: RoutePaths.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: RoutePaths.promiseDetailPattern,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return PromiseDetailScreen(intentionId: id);
        },
      ),
    ],
  );
});

/// Bridges the onboarding flag into [GoRouter]'s refresh mechanism.
class _OnboardingSignal extends ChangeNotifier {
  _OnboardingSignal(Ref ref) {
    _subscription = ref.listen(
      onboardingCompleteProvider,
      (_, _) => notifyListeners(),
    );
    ref.onDispose(dispose);
  }

  late final ProviderSubscription<AsyncValue<bool>> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
