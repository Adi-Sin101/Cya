import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/cya_colors_extension.dart';
import '../../providers/settings_providers.dart';

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

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.cyaColors.surface2,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'lib/assets/images/cya-logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Profile', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Settings and progress for Cya!',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Card(
            child: SwitchListTile.adaptive(
              key: const ValueKey<String>('profile-dark-mode-switch'),
              value: isDark,
              onChanged: (enabled) {
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: Icon(Icons.emoji_events_rounded, color: colors.primary),
              title: Text('Achievements', style: theme.textTheme.titleMedium),
              subtitle: Text('Coming soon', style: theme.textTheme.bodySmall),
            ),
          ),
        ],
      ),
    );
  }
}
