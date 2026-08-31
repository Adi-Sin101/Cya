import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/achievements/achievements_screen.dart';
import '../../presentation/screens/garden/garden_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
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
    routes: <RouteBase>[
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
