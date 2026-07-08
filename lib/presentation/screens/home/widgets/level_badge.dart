import 'package:flutter/material.dart';

import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../domain/models/user_level.dart';

/// The gamification level pill + XP progress bar (PRD §6.6, §8.2).
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level});

  final UserLevel level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cya.surface2),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[Color(0xFF2E705B), Color(0xFF74B69D)],
              ),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Level ${level.level} · ${level.title}',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: level.progress,
                    minHeight: 7,
                    backgroundColor: cya.surface2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_grouped(level.xp)} / ${_grouped(level.xpTarget)} XP',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Groups an integer with thousands separators, e.g. 2450 -> "2,450".
String _grouped(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
