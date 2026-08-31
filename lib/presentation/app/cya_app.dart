import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_theme.dart';
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

  /// `cya://promise/<id>` → the promise detail screen.
  void _handleDeepLink(String? link) {
    if (link == null || !mounted) return;
    final uri = Uri.tryParse(link);
    if (uri == null || uri.host != 'promise') return;
    final id = int.tryParse(uri.pathSegments.firstOrNull ?? '');
    if (id == null) return;
    ref.read(goRouterProvider).push(RoutePaths.promiseDetail(id));
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
    );
  }
}
