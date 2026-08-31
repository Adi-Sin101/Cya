import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/cya_haptics.dart';
import '../../providers/intention_providers.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/motion/entrance.dart';
import '../home/widgets/level_badge.dart';

/// Profile: who Cya! thinks you are, and the handful of switches worth having
/// (PRD §8.2).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && theme.brightness == Brightness.dark);
    final name = ref.watch(displayNameProvider).valueOrNull;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xl,
          AppSpacing.page,
          AppSpacing.navClearance,
        ),
        children: Entrance.staggered(<Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(AppSpacing.sm - 2),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'lib/assets/images/cya-logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name == null || name.trim().isEmpty ? 'You' : name,
                      style: theme.textTheme.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Everything here stays on this phone.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          LevelBadge(level: ref.watch(userLevelProvider)),
          const SizedBox(height: AppSpacing.xxl),

          _SectionLabel('You'),
          _Tile(
            icon: Icons.badge_outlined,
            title: 'Your name',
            subtitle: name == null || name.trim().isEmpty
                ? 'Cya! greets you by name once it knows one'
                : name,
            onTap: () => _editName(context, ref, name),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: SwitchListTile.adaptive(
              key: const ValueKey<String>('profile-dark-mode-switch'),
              value: isDark,
              onChanged: (enabled) {
                CyaHaptics.selection(context);
                ref
                    .read(settingsControllerProvider)
                    .setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
              },
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: colors.primary,
              ),
              title: Text('Dark mode', style: theme.textTheme.titleMedium),
              subtitle: Text(
                isDark
                    ? 'Using the calm night palette'
                    : 'Using the bright garden palette',
                style: theme.textTheme.bodySmall,
              ),
              activeThumbColor: colors.primary,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
          _SectionLabel('Progress'),
          _Tile(
            icon: Icons.emoji_events_rounded,
            title: 'Achievements',
            subtitle: _achievementSubtitle(ref),
            onTap: () => context.push(RoutePaths.achievements),
          ),
          const SizedBox(height: AppSpacing.md),
          _Tile(
            icon: Icons.local_florist_rounded,
            title: 'Memory Garden',
            subtitle: () {
              final scene = ref.watch(gardenSceneProvider);
              return switch (scene.totalGrowths) {
                0 => 'Nothing growing yet',
                1 => '1 promise kept',
                final total => '$total promises kept',
              };
            }(),
            onTap: () => context.go(RoutePaths.garden),
          ),
          const SizedBox(height: AppSpacing.md),
          _Tile(
            icon: Icons.auto_stories_rounded,
            title: 'Weekly review',
            subtitle: 'How last week actually went',
            onTap: () => context.push(RoutePaths.digest),
          ),
        ]),
      ),
    );
  }

  String _achievementSubtitle(WidgetRef ref) {
    final unlocked = ref
        .watch(achievementsProvider)
        .where((a) => a.isUnlocked)
        .length;
    return unlocked == 0
        ? 'Your first badge is one promise away'
        : '$unlocked unlocked';
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    CyaHaptics.tap(context);
    final controller = TextEditingController(text: current ?? '');
    final saved = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('What should I call you?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Your first name'),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved == null) return;
    await ref.read(settingsControllerProvider).setDisplayName(saved);
    if (context.mounted) CyaHaptics.confirm(context);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.md,
      ),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.4,
          color: context.cyaColors.textSecondary,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: context.cyaColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
