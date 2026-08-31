import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/utils/cya_haptics.dart';
import '../screens/capture/capture_sheet.dart';
import 'widgets/cya_bottom_nav.dart';

/// The persistent app shell: the current tab's content, the notched bottom nav,
/// and the center capture (+) FAB (PRD §8.2).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab returns it to its initial route.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Deliberately NOT extendBody. The FAB's notch is a hole in the nav bar,
      // and with the body extended underneath it framed a sliver of whatever
      // list row happened to be scrolling past — which reads as a glitch. With
      // the body stopping at the bar, the notch shows the page background.
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const _CaptureFab(),
      bottomNavigationBar: CyaBottomNav(
        currentIndex: navigationShell.currentIndex,
        onSelect: _goBranch,
      ),
    );
  }
}

/// The capture button. The single most important control in the app, so it is
/// the only one that springs under the finger and carries its own glow
/// (PRD §8.2).
///
/// The glow is static. An earlier version breathed on a three-second loop,
/// which looked lovely and cost a repaint every frame for the entire life of
/// the app — on every screen, forever. "Resource-conscious" (PRD §9.4) rules
/// that out for decoration: continuous motion is reserved for the garden,
/// where it is the point.
class _CaptureFab extends StatefulWidget {
  const _CaptureFab();

  @override
  State<_CaptureFab> createState() => _CaptureFabState();
}

class _CaptureFabState extends State<_CaptureFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: AppMotion.instant,
    reverseDuration: AppMotion.quick,
  );

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _open() {
    CyaHaptics.confirm(context);
    showCaptureSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Capture a promise',
      child: GestureDetector(
        onTapDown: (_) => _press.forward(),
        onTapUp: (_) => _press.reverse(),
        onTapCancel: () => _press.reverse(),
        onTap: _open,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _press,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[AppColors.sage, AppColors.softSage],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.sage.withValues(alpha: 0.38),
                    blurRadius: 22,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            builder: (context, child) => Transform.scale(
              scale: 1 - 0.09 * AppMotion.standard.transform(_press.value),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
