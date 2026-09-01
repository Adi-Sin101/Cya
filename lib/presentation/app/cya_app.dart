import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/system_chrome.dart';
import '../providers/identity_providers.dart';
import '../providers/reminder_providers.dart';
import '../providers/settings_providers.dart';
import '../screens/lock/lock_gate.dart';

/// Root widget: wires the router and the light/dark themes, routes reminder
/// deep links, and re-arms alarms when the app comes back.
class CyaApp extends ConsumerStatefulWidget {
  const CyaApp({super.key});

  @override
  ConsumerState<CyaApp> createState() => _CyaAppState();
}

class _CyaAppState extends ConsumerState<CyaApp> with WidgetsBindingObserver {
  /// When the app was last backgrounded, or null if it has not been.
  DateTime? _leftAt;

  /// How long the app may sit in the background before the PIN is asked for
  /// again.
  ///
  /// Not zero. Sharing *into* Cya! bounces through another app, and a lock that
  /// re-arms the instant focus leaves would demand a PIN after every capture —
  /// which would put a four-digit toll on the two-second path the whole product
  /// is built to protect (PRD §3.1). A minute covers the round trip and still
  /// locks a phone left on a table.
  static const Duration _relockAfter = Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final port = ref.read(reminderPortProvider);
    // A notification tapped while the app was not running (PRD §3.4 — one-tap
    // resolution has to be reachable *from the notification*).
    port.consumeInitialDeepLink().then(_handleDeepLink);
    port.onDeepLink(_handleDeepLink);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _leftAt = ref.read(clockProvider)();
      return;
    }
    if (state != AppLifecycleState.resumed) return;

    final leftAt = _leftAt;
    if (leftAt != null &&
        ref.read(clockProvider)().difference(leftAt) >= _relockAfter) {
      ref.read(sessionLockProvider.notifier).lock();
    }
    _leftAt = null;

    // Cheap insurance against an OEM that dropped alarms while we were away,
    // and a fresh look at whether reminders are actually arriving (PRD §12).
    ref.read(reminderPortProvider).rescheduleAll();
    ref.invalidate(reminderHealthProvider);
  }

  /// `cya://promise/<id>` → promise detail; `cya://digest` → the weekly review.
  void _handleDeepLink(String? link) {
    if (link == null || !mounted) return;
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    switch (uri.host) {
      case 'promise':
        final id = int.tryParse(uri.pathSegments.firstOrNull ?? '');
        if (id != null) {
          ref.read(goRouterProvider).push(RoutePaths.promiseDetail(id));
        }
      case 'digest':
        ref.read(goRouterProvider).push(RoutePaths.digest);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cya!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(goRouterProvider),
      // Clamps the OS text scale to a range these layouts survive, and keeps
      // the system bar icons matched to the resolved theme (PRD §8.4).
      // The lock sits inside the theme and above the navigator, so it covers
      // routes, sheets and dialogs alike (see [LockGate]).
      builder: (context, child) => SystemChromeSync(
        child: AppTheme.wrapMediaQuery(
          context,
          LockGate(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
