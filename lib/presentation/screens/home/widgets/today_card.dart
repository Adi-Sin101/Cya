import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../widgets/motion/animated_counter.dart';
import 'completion_ring.dart';

/// The hero "Today" card: promise count + completion ring on the brand
/// gradient (PRD §8.2).
///
/// This is the one thing on Home allowed to shout. Everything else on the
/// screen is deliberately quieter so that a glance lands here first.
class TodayCard extends StatelessWidget {
  const TodayCard({super.key, required this.total, required this.completed});

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = (total - completed).clamp(0, total);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl + 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        // The brand gradient, weighted so the deep end covers the text.
        //
        // A straight three-stop sage→mint ramp puts white copy on mint at
        // 1.6:1 and the ring at 2.4:1 — unreadable (PRD §8.4). Holding sage
        // through the first 45% gives the white text a 5.9:1 field, and the
        // mint corner is left for the ring, which is drawn in deep ink.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.sage,
            AppColors.sage,
            AppColors.softSage,
            AppColors.mint,
          ],
          stops: <double>[0, 0.45, 0.78, 1],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.sage.withValues(alpha: 0.30),
            blurRadius: 26,
            spreadRadius: -6,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'TODAY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    AnimatedCounter(
                      value: total,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      total == 1 ? 'promise' : 'promises',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                FadingText(
                  _subtitle(total, completed, remaining),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Deep ink, not white: the ring sits over the gradient's mint corner
          // where white would vanish.
          CompletionRing(
            completed: completed,
            total: total,
            size: 96,
            strokeWidth: 10,
            trackColor: AppColors.deepInk.withValues(alpha: 0.18),
            progressColors: const <Color>[AppColors.deepInk, AppColors.deepInk],
            textColor: AppColors.deepInk,
          ),
        ],
      ),
    );
  }
}

/// Says the same thing four ways depending on where the day is, because
/// "0 completed · 0 to go" on an empty day is a status line, not a sentence.
String _subtitle(int total, int completed, int remaining) {
  if (total == 0) return 'Nothing due. Enjoy it.';
  if (remaining == 0) return 'All of them. Every one.';
  if (completed == 0) return '$remaining to go';
  return '$completed done · $remaining to go';
}
