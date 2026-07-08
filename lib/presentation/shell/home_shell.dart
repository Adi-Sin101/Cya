import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    final theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _CaptureFab(
        onPressed: () => showCaptureSheet(context),
        colors: theme.colorScheme,
      ),
      bottomNavigationBar: CyaBottomNav(
        currentIndex: navigationShell.currentIndex,
        onSelect: _goBranch,
      ),
    );
  }
}

class _CaptureFab extends StatelessWidget {
  const _CaptureFab({required this.onPressed, required this.colors});

  final VoidCallback onPressed;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E705B), Color(0xFF74B69D)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E705B).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
