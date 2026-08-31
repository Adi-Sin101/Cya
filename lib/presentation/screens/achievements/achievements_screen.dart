import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/cya_colors_extension.dart';
import '../../../domain/projections/achievement_projection.dart';
import '../../providers/intention_providers.dart';

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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Text(
            unlocked == 0
                ? 'Nothing unlocked yet — the first one is one promise away.'
                : '$unlocked of ${achievements.length} unlocked.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) =>
                _AchievementCard(achievement: achievements[index]),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: unlocked ? null : theme.colorScheme.surface,
        gradient: unlocked
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFFA7D7C5), Color(0xFF74B69D)],
              )
            : null,
        border: Border.all(color: unlocked ? Colors.transparent : cya.surface2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Opacity(
            opacity: unlocked ? 1 : 0.35,
            child: Text(
              achievement.emoji,
              style: const TextStyle(fontSize: 30),
            ),
          ),
          const Spacer(),
          Text(
            achievement.name,
            style: theme.textTheme.titleSmall?.copyWith(
              color: unlocked ? const Color(0xFF14532D) : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: unlocked
                  ? const Color(0xFF14532D).withValues(alpha: 0.85)
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          if (unlocked)
            Row(
              children: <Widget>[
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: Color(0xFF14532D),
                ),
                const SizedBox(width: 6),
                Text(
                  'Unlocked',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF14532D),
                  ),
                ),
              ],
            )
          else ...<Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: achievement.fraction,
                minHeight: 6,
                backgroundColor: cya.surface2,
              ),
            ),
            const SizedBox(height: 5),
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
