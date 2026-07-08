import 'package:flutter/material.dart';

import '../../../../domain/enums/reminder_preset.dart';

/// A small tinted pill showing a reminder preset (PRD §6.2, §8.2).
class PresetChip extends StatelessWidget {
  const PresetChip({super.key, required this.preset});

  final ReminderPreset preset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _visual(preset, theme.colorScheme);
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
            preset.label,
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

(IconData, Color) _visual(ReminderPreset preset, ColorScheme colors) {
  return switch (preset) {
    ReminderPreset.tonight => (Icons.nightlight_round, colors.primary),
    ReminderPreset.tomorrow => (
      Icons.wb_twilight_rounded,
      const Color(0xFFF59E0B),
    ),
    ReminderPreset.weekend => (Icons.weekend_rounded, colors.secondary),
  };
}
