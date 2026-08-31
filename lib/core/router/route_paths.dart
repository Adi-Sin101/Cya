/// Canonical route locations for the app shell (PRD §8.2 bottom nav).
abstract final class RoutePaths {
  const RoutePaths._();

  static const String home = '/home';
  static const String promises = '/promises';
  static const String garden = '/garden';
  static const String profile = '/profile';

  /// Promise detail / resurface screen. Kept outside the shell so it covers
  /// the bottom nav, and deep-linkable so a notification can open it directly
  /// (PRD §3.4 — one-tap resolution reachable from the notification).
  static const String promiseDetailPattern = '/promise/:id';

  static String promiseDetail(int id) => '/promise/$id';
}
