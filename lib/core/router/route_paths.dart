/// Canonical route locations for the app shell (PRD §8.2 bottom nav).
abstract final class RoutePaths {
  const RoutePaths._();

  /// First-run flow (ADR-010). Three locations rather than one stateful screen
  /// so an interrupted install resumes at the step it stopped on, and so the
  /// back gesture means the same thing here as everywhere else.
  static const String onboarding = '/welcome';
  static const String profileSetup = '/welcome/profile';
  static const String lockSetup = '/welcome/lock';

  /// The unlock gate. Not a route: it is drawn *over* whatever the router
  /// resolved, so a reminder deep link survives being locked — the promise is
  /// already loaded behind the PIN and appears the moment it is entered.
  ///
  /// See `LockGate` in `cya_app.dart`.

  /// Setting or replacing the PIN after onboarding, opened from Profile. A
  /// separate location from [lockSetup] because anything under [onboarding] is
  /// redirected away once the flow is complete.
  static const String lockSettings = '/lock-settings';

  static const String home = '/home';
  static const String promises = '/promises';
  static const String garden = '/garden';
  static const String profile = '/profile';

  /// Promise detail / resurface screen. Kept outside the shell so it covers
  /// the bottom nav, and deep-linkable so a notification can open it directly
  /// (PRD §3.4 — one-tap resolution reachable from the notification).
  static const String promiseDetailPattern = '/promise/:id';

  static String promiseDetail(int id) => '/promise/$id';

  /// Full achievements grid, opened from Profile (PRD §8.2).
  static const String achievements = '/achievements';

  /// The weekly review, opened from the digest notification (PRD §5.6).
  static const String digest = '/digest';
}
