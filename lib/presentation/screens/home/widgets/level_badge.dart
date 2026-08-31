import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../domain/models/user_level.dart';

/// The gamification level + XP progress (PRD §6.6, §8.2).
///
/// A line, not a card: an icon, the level, and a bar that fills toward the
/// next one. The XP figure sits at the end of the bar rather than under it, so
/// the whole thing is one row of information instead of three.
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level});

  final UserLevel level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    return Semantics(
      label:
          'Level ${level.level}, ${level.title}. '
          '${level.xp} of ${level.xpTarget} experience.',
      child: ExcludeSemantics(
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondaryContainer,
              ),
              child: Icon(
                Icons.eco_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Level ${level.level} · ${level.title}',
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${_grouped(level.xp)} / ${_grouped(level.xpTarget)}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    // The bar fills toward its value rather than appearing at
                    // it — the one place on Home where progress is visibly
                    // *progress*.
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: level.progress),
                      duration: AppMotion.of(context, AppMotion.slow),
                      curve: AppMotion.enter,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 7,
                        backgroundColor: cya.surface2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
