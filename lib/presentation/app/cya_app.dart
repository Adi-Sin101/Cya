import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/system_chrome.dart';
import '../providers/reminder_providers.dart';
import '../providers/settings_providers.dart';

/// Root widget: wires the router and the light/dark themes, routes reminder
/// deep links, and re-arms alarms when the app comes back.
class CyaApp extends ConsumerStatefulWidget {
  const CyaApp({super.key});

  @override
  ConsumerState<CyaApp> createState() => _CyaAppState();
}

class _CyaAppState extends ConsumerState<CyaApp> with WidgetsBindingObserver {
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
    if (state != AppLifecycleState.resumed) return;
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
      builder: (context, child) =>
          SystemChromeSync(child: AppTheme.wrapMediaQuery(context, child)),
    );
  }
}
