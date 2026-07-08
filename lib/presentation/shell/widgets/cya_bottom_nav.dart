import 'package:flutter/material.dart';

import '../../../core/theme/cya_colors_extension.dart';

/// The notched bottom navigation bar (PRD §8.2): Home · Promises · (+) · Garden
/// · Profile. The center slot is a gap for the docked capture FAB, so the four
/// visual items map directly to the four shell branch indices.
class CyaBottomNav extends StatelessWidget {
  const CyaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BottomAppBar(
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black26,
      height: 66,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        children: <Widget>[
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: currentIndex == 0,
            onTap: () => onSelect(0),
          ),
          _NavItem(
            icon: Icons.bookmark_rounded,
            label: 'Promises',
            selected: currentIndex == 1,
            onTap: () => onSelect(1),
          ),
          const SizedBox(width: 64),
          _NavItem(
            icon: Icons.spa_rounded,
            label: 'Garden',
            selected: currentIndex == 2,
            onTap: () => onSelect(2),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: currentIndex == 3,
            onTap: () => onSelect(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : context.cyaColors.textSecondary;
    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
