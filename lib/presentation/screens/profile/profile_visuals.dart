import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_motion.dart';
import '../../providers/intention_providers.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/profile_avatar_view.dart';
import '../../widgets/motion/pressable.dart';

class ProfileIdentityVisual extends ConsumerWidget {
  const ProfileIdentityVisual({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context), colors = theme.colorScheme;
    final name = ref.watch(displayNameProvider).valueOrNull;
    final level = ref.watch(userLevelProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your little corner.', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 24),
        Row(
          children: [
            Semantics(
              label:
                  'Level ${level.level}, ${level.xp} of ${level.xpTarget} experience.',
              child: SizedBox(
                width: 104,
                height: 104,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: level.progress),
                        duration: AppMotion.of(context, AppMotion.slow),
                        curve: AppMotion.enter,
                        builder: (context, value, _) =>
                            CircularProgressIndicator(
                              value: value,
                              strokeWidth: 5,
                              strokeCap: StrokeCap.round,
                              color: colors.primary,
                              backgroundColor: colors.secondaryContainer,
                            ),
                      ),
                    ),
                    ProfileAvatarView(
                      avatar: ref.watch(profileAvatarProvider),
                      size: 80,
                      selected: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name == null || name.trim().isEmpty ? 'You' : name,
                    style: theme.textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Level ${level.level} · ${level.title}',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${level.xp} / ${level.xpTarget} XP',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(Icons.phone_android_rounded, size: 18, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your space, on this phone.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfileMilestones extends ConsumerWidget {
  const ProfileMilestones({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context), colors = theme.colorScheme;
    final badges = ref.watch(achievementsProvider);
    final earned = badges.where((b) => b.isUnlocked).length;
    return Pressable(
      semanticLabel: 'Open achievements. $earned of ${badges.length} unlocked.',
      onTap: () => context.push(RoutePaths.achievements),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Achievements',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: colors.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$earned of ${badges.length} unlocked',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final badge in badges.take(3))
                  SizedBox(
                    width: 72,
                    child: Semantics(
                      label:
                          '${badge.name}: ${badge.progress} of ${badge.target}. ${badge.isUnlocked ? 'Unlocked' : 'In progress'}',
                      child: ExcludeSemantics(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: CircularProgressIndicator(
                                    value: badge.fraction,
                                    strokeWidth: 3,
                                    color: colors.primary,
                                    backgroundColor: colors.outlineVariant,
                                  ),
                                ),
                                Icon(
                                  badge.isUnlocked
                                      ? Icons.workspace_premium_rounded
                                      : Icons.eco_outlined,
                                  color: badge.isUnlocked
                                      ? colors.primary
                                      : colors.onSurfaceVariant,
                                  size: 26,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              badge.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
