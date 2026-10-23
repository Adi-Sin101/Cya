import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_motion.dart';
import '../../core/utils/cya_haptics.dart';
import '../screens/capture/capture_hub.dart';
import 'widgets/cya_bottom_nav.dart';

/// Preserved tab state and the compact corner capture action.
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
      // Tab lists retain bottom scroll clearance for the hovering capture action.
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const _CaptureFab(),
      bottomNavigationBar: CyaBottomNav(
        currentIndex: navigationShell.currentIndex,
        onSelect: _goBranch,
      ),
    );
  }
}

/// Compact capture action with theme-aware contrast and quiet press feedback.
class _CaptureFab extends ConsumerStatefulWidget {
  const _CaptureFab();

  @override
  ConsumerState<_CaptureFab> createState() => _CaptureFabState();
}

class _CaptureFabState extends ConsumerState<_CaptureFab>
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
    showCaptureHub(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Capture',
      child: GestureDetector(
        onTapDown: (_) => _press.forward(),
        onTapUp: (_) => _press.reverse(),
        onTapCancel: () => _press.reverse(),
        onTap: _open,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _press,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: colors.primary,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.16),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.add_rounded, color: colors.onPrimary, size: 28),
            ),
            builder: (context, child) => Transform.scale(
              scale: AppMotion.isReduced(context)
                  ? 1
                  : 1 - 0.06 * AppMotion.standard.transform(_press.value),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
