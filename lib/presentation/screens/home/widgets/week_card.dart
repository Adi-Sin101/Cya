import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../domain/models/week_stats.dart';
import '../../../../domain/projections/garden_projection.dart';
import '../../../widgets/motion/animated_counter.dart';
import '../../../widgets/motion/pressable.dart';
import '../../garden/widgets/garden_scene_view.dart';

/// "This week", as one card: a living strip of the garden over the three
/// numbers behind it (PRD §6.6, §8.2).
///
/// These used to be two cards — a Memory Garden teaser with emoji plants, and a
/// stats block with a sparkline. They answer the same question ("how did this
/// week go?") and stacking them made Home read as a dashboard. One card, one
/// question: the garden strip *is* the trend line, drawn out of the same
/// resolutions the numbers count.
class WeekCard extends StatelessWidget {
  const WeekCard({
    super.key,
    required this.stats,
    required this.plants,
    required this.now,
    this.onTap,
  });

  final WeekStats stats;

  /// This week's kept promises, drawn as the strip along the top.
  final List<GardenPlant> plants;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rate = (stats.successRate * 100).round();

    return Pressable(
      onTap: onTap,
      semanticLabel:
          'This week: ${stats.captured} captured, '
          '${stats.completed} completed. Open the garden.',
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // The garden bleeds to the card's edges — it is scenery, not a
            // chart in a frame. Still, though: the wind belongs on the Garden
            // screen, where the user went to look at it. Home is a screen you
            // are passing through.
            GardenSceneView(
              plants: plants,
              height: 128,
              now: now,
              plantScale: 1.15,
              animateWind: false,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'This week',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.cyaColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _Stat(
                          value: stats.captured,
                          label: 'captured',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: _Stat(
                          value: stats.completed,
                          label: 'kept',
                          color: context.cyaColors.successInk,
                        ),
                      ),
                      Expanded(
                        child: _Stat(
                          value: rate,
                          suffix: '%',
                          label: 'success',
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
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

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.color,
    this.suffix = '',
  });

  final int value;
  final String label;
  final Color color;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AnimatedCounter(
          value: value,
          suffix: suffix,
          style: theme.textTheme.headlineMedium?.copyWith(color: color),
        ),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}
