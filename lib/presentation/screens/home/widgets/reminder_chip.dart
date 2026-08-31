import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
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
    final (icon, color) = _visual(
      display.kind,
      theme.colorScheme,
      context.cyaColors,
    );
    final overdue = display.kind == ReminderKind.overdue;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: overdue ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm - 2),
        // Overdue gets an outline as well as a colour, so it is still the
        // loudest chip in the row for a user who cannot see the red.
        border: overdue
            ? Border.all(color: color.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs + 1),
          Text(
            display.chipLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

(IconData, Color) _visual(
  ReminderKind kind,
  ColorScheme colors,
  CyaColors cya,
) {
  // Inks, not fills: this chip is a colour carrying 12px letters, and the raw
  // §8.1 error/warning values fall under 4.5:1 on white (PRD §8.4).
  return switch (kind) {
    ReminderKind.overdue => (Icons.error_outline_rounded, cya.errorInk),
    ReminderKind.tonight => (Icons.nightlight_round, colors.primary),
    ReminderKind.today => (Icons.wb_sunny_rounded, colors.primary),
    ReminderKind.tomorrow => (Icons.wb_twilight_rounded, cya.warningInk),
    ReminderKind.weekend => (Icons.weekend_rounded, colors.secondary),
    ReminderKind.later => (Icons.event_rounded, colors.secondary),
    ReminderKind.none => (Icons.all_inclusive_rounded, colors.outline),
  };
}
