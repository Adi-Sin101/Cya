import 'package:flutter/material.dart';

import '../../../../core/utils/reminder_format.dart';

/// A small tinted pill showing when a promise comes back (PRD §6.2, §8.2).
///
/// The label is derived from the stored reminder time, not from a saved preset,
/// so it stays truthful as time passes.
class ReminderChip extends StatelessWidget {
  const ReminderChip({super.key, required this.display});

  final ReminderDisplay display;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _visual(display.kind, theme.colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            display.chipLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

(IconData, Color) _visual(ReminderKind kind, ColorScheme colors) {
  return switch (kind) {
    ReminderKind.overdue => (
      Icons.error_outline_rounded,
      const Color(0xFFEF4444),
    ),
    ReminderKind.tonight => (Icons.nightlight_round, colors.primary),
    ReminderKind.today => (Icons.wb_sunny_rounded, colors.primary),
    ReminderKind.tomorrow => (
      Icons.wb_twilight_rounded,
      const Color(0xFFF59E0B),
    ),
    ReminderKind.weekend => (Icons.weekend_rounded, colors.secondary),
    ReminderKind.later => (Icons.event_rounded, colors.secondary),
    ReminderKind.none => (Icons.all_inclusive_rounded, colors.outline),
  };
}
