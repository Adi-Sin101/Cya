import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/cya_haptics.dart';

/// The notched bottom navigation bar (PRD §8.2): Home · Promises · (+) · Garden
/// · Profile. The center slot is a gap for the docked capture FAB, so the four
/// visual items map directly to the four shell branch indices.
///
/// Selection is animated per item rather than by moving a shared indicator: the
/// four tabs are far apart around a notch, and a pill sliding across the gap
/// draws the eye to the empty middle instead of to where you landed.
class CyaBottomNav extends StatelessWidget {
  const CyaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const List<({IconData icon, IconData active, String label})> _items =
      <({IconData icon, IconData active, String label})>[
        (icon: Icons.home_outlined, active: Icons.home_rounded, label: 'Home'),
        (
          icon: Icons.bookmark_border_rounded,
          active: Icons.bookmark_rounded,
          label: 'Promises',
        ),
        (icon: Icons.spa_outlined, active: Icons.spa_rounded, label: 'Garden'),
        (
          icon: Icons.person_outline_rounded,
          active: Icons.person_rounded,
          label: 'Profile',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget item(int index) => _NavItem(
      icon: _items[index].icon,
      activeIcon: _items[index].active,
      label: _items[index].label,
      selected: currentIndex == index,
      onTap: () {
        if (currentIndex != index) CyaHaptics.tap(context);
        onSelect(index);
      },
    );

    // Elevation rather than a drawn top border: a border is a straight line
    // and would cut across the FAB's notch, which reads as a rendering bug.
    // The shadow follows the notched shape for free.
    return BottomAppBar(
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      shadowColor: context.cyaColors.shadow,
      height: 78,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: Row(
        children: <Widget>[
          item(0),
          item(1),
          const SizedBox(width: 72),
          item(2),
          item(3),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : context.cyaColors.textSecondary;
    final duration = AppMotion.of(context, AppMotion.quick);

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkResponse(
          onTap: onTap,
          radius: 48,
          containedInkWell: false,
          child: SizedBox(
            height: AppTouch.minTarget + 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // The selected tab's icon sits in a tinted pill and swaps to
                // its filled variant — two signals, so the tab is legible
                // without relying on colour alone (PRD §8.4).
                AnimatedContainer(
                  duration: duration,
                  curve: AppMotion.standard,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs + 1,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.secondaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    selected ? activeIcon : icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: duration,
                  curve: AppMotion.standard,
                  style:
                      theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ) ??
                      const TextStyle(),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
