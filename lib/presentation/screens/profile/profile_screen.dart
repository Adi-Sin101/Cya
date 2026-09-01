import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/cya_haptics.dart';
import '../../../domain/entities/lock_settings.dart';
import '../../../native/biometric_port.dart';
import '../../providers/identity_providers.dart';
import '../../providers/intention_providers.dart';
import '../../providers/privacy_providers.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/motion/entrance.dart';
import '../../widgets/profile_avatar_view.dart';
import '../home/widgets/level_badge.dart';
import '../lock/widgets/pin_pad.dart';

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
              ProfileAvatarView(
                avatar: ref.watch(profileAvatarProvider),
                size: 76,
                selected: true,
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

          const SizedBox(height: AppSpacing.xxl),
          _SectionLabel('Privacy'),
          ..._lockTiles(context, ref),
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

  /// The device lock, and the fingerprint shortcut when one is possible
  /// (ADR-010). Shown under Privacy rather than under You, because this is the
  /// only control on the screen that changes who can read the promises.
  List<Widget> _lockTiles(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(lockSettingsProvider).valueOrNull ?? LockSettings.open;
    final biometricReady =
        ref.watch(biometricAvailabilityProvider).valueOrNull ==
        BiometricAvailability.ready;

    return <Widget>[
      _Tile(
        icon: lock.hasPin ? Icons.lock_rounded : Icons.lock_open_rounded,
        title: 'App lock',
        subtitle: lock.hasPin
            ? 'A PIN is needed to open Cya!'
            : 'Anyone who opens your phone can read these',
        onTap: () => context.push(RoutePaths.lockSettings),
      ),
      if (lock.hasPin) ...<Widget>[
        const SizedBox(height: AppSpacing.md),
        if (biometricReady)
          Card(
            child: SwitchListTile.adaptive(
              key: const ValueKey<String>('profile-biometric-switch'),
              value: lock.biometricEnabled,
              onChanged: (enabled) {
                CyaHaptics.selection(context);
                ref.read(lockRepositoryProvider).setBiometricEnabled(enabled);
              },
              secondary: Icon(
                Icons.fingerprint_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Unlock with fingerprint',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                'The PIN still works whenever you prefer it',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        if (biometricReady) const SizedBox(height: AppSpacing.md),
        _Tile(
          icon: Icons.lock_open_rounded,
          title: 'Turn off the lock',
          subtitle: 'Cya! will open without asking',
          onTap: () => _removeLock(context, ref),
        ),
      ],
      const SizedBox(height: AppSpacing.md),
      _Tile(
        icon: Icons.download_rounded,
        title: 'Export my data',
        subtitle: 'Every promise and every event, as a readable file',
        onTap: () => _export(context, ref),
      ),
      const SizedBox(height: AppSpacing.md),
      _Tile(
        icon: Icons.delete_forever_rounded,
        title: 'Delete everything',
        subtitle: 'Promises, history, profile and lock — all of it',
        onTap: () => _eraseEverything(context, ref),
      ),
    ];
  }

  /// Hands the whole store to the share sheet (PRD §9.3).
  Future<void> _export(BuildContext context, WidgetRef ref) async {
    CyaHaptics.tap(context);
    final result = await ref.read(privacyControllerProvider).exportEverything();
    if (!context.mounted) return;
    result.fold(
      (count) {
        CyaHaptics.confirm(context);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                count == 1
                    ? '1 promise exported.'
                    : '$count promises exported.',
              ),
            ),
          );
      },
      (error) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message))),
    );
  }

  /// The one irreversible thing in the app (PRD §9.3).
  ///
  /// Guarded by a typed confirmation rather than a second "are you sure?": a
  /// dialog anyone dismisses reflexively is not consent, and this is the only
  /// action here that cannot be undone from the event log — because the event
  /// log is part of what goes.
  Future<void> _eraseEverything(BuildContext context, WidgetRef ref) async {
    CyaHaptics.warn(context);
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Delete everything?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Every promise, the whole history, your name and your PIN. '
                'Nothing here is on a server, so there is no copy to restore '
                'from. Export first if you want one.',
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: controller,
                autofocus: true,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Type DELETE to confirm',
                ),
                onChanged: (_) => setDialogState(() {}),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep everything'),
            ),
            FilledButton(
              onPressed: controller.text.trim().toUpperCase() == 'DELETE'
                  ? () => Navigator.of(dialogContext).pop(true)
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (confirmed != true || !context.mounted) return;

    final result = await ref.read(privacyControllerProvider).eraseEverything();
    if (!context.mounted) return;
    result.fold(
      (count) {
        CyaHaptics.confirm(context);
        // Back to the beginning: with the profile gone there is nothing for
        // Home to greet, and the router sends a store with no onboarding flag
        // through the welcome flow again.
        context.go(RoutePaths.onboarding);
      },
      (error) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message))),
    );
  }

  /// Removing the lock asks for the PIN first. Anything less would mean a phone
  /// left unlocked on a table could disarm the thing protecting it.
  Future<void> _removeLock(BuildContext context, WidgetRef ref) async {
    CyaHaptics.tap(context);
    final controller = TextEditingController();
    final entered = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Turn off the lock?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Enter your PIN to confirm.'),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: kPinLength,
              decoration: const InputDecoration(counterText: ''),
              onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Turn off'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (entered == null || !context.mounted) return;

    final verdict = await ref.read(lockRepositoryProvider).verify(entered);
    if (!context.mounted) return;
    if (verdict is PinAccepted) {
      await ref.read(lockRepositoryProvider).disable();
      if (!context.mounted) return;
      CyaHaptics.confirm(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lock removed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      CyaHaptics.warn(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("That PIN didn't match. The lock is still on."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
