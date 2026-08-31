import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../domain/projections/achievement_projection.dart';
import '../../providers/intention_providers.dart';
import '../../widgets/motion/entrance.dart';

/// Achievements (PRD §6.6, §8.2): a grid of badges with locked/unlocked states.
///
/// Every badge is a predicate over counts, evaluated on the spot — there is no
/// stored "unlocked" flag that could disagree with the event log (ADR-002).
/// Locked badges show real progress rather than a blank silhouette: knowing you
/// are 12 promises from *Never Lost* is the encouraging part.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider);
    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.section,
        ),
        children: <Widget>[
          Text(
            unlocked == 0
                ? 'Nothing unlocked yet — the first one is one promise away.'
                : '$unlocked of ${achievements.length} unlocked.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: context.cyaColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.78,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) => Entrance(
              delay: Duration(milliseconds: 50 * index),
              child: _AchievementCard(achievement: achievements[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    final unlocked = achievement.isUnlocked;
    // The unlocked fill is mint in both themes, so its foreground is deep ink
    // in both themes — `onSurface` would be white-on-mint in dark (PRD §8.4).
    final ink = unlocked ? AppColors.deepInk : theme.colorScheme.onSurface;

    return AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.gentle),
      curve: AppMotion.standard,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: unlocked ? null : theme.colorScheme.surface,
        gradient: unlocked
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.mint, AppColors.softSage],
              )
            : null,
        border: Border.all(
          color: unlocked
              ? Colors.transparent
              : theme.colorScheme.outlineVariant,
        ),
        boxShadow: unlocked ? cyaShadow(context, elevation: 0.6) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: unlocked ? 1 : 0.3,
            child: Text(
              achievement.emoji,
              style: const TextStyle(fontSize: 34),
            ),
          ),
          const Spacer(),
          Text(
            achievement.name,
            style: theme.textTheme.titleSmall?.copyWith(color: ink),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            achievement.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: unlocked
                  ? AppColors.deepInk.withValues(alpha: 0.85)
                  : cya.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (unlocked)
            Row(
              children: <Widget>[
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppColors.deepInk,
                ),
                const SizedBox(width: AppSpacing.xs + 2),
                Text(
                  'Unlocked',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.deepInk,
                  ),
                ),
              ],
            )
          else ...<Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: achievement.fraction),
                duration: AppMotion.of(context, AppMotion.slow),
                curve: AppMotion.enter,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: cya.surface2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              '${achievement.progress} / ${achievement.target}',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}
