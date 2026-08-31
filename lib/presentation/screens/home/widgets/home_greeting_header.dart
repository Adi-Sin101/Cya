import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../domain/models/user_level.dart';
import 'level_badge.dart';

/// Time-aware greeting + level at the top of Home (PRD §8.2).
///
/// The level used to be a bordered card competing with the Today hero
/// immediately below it. It is now a line under the greeting: still visible
/// every session, no longer arguing for the same attention as the one thing
/// the screen is about.
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({
    super.key,
    required this.level,
    required this.now,
    this.userName,
  });

  /// `null` until the user tells Cya! their name — the greeting still works.
  final String? userName;
  final UserLevel level;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = userName?.trim();
    final greeting = _greeting(now.hour);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          name == null || name.isEmpty ? greeting : '$greeting, $name',
          style: theme.textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _encouragement(now.hour),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: context.cyaColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        LevelBadge(level: level),
      ],
    );
  }
}

String _greeting(int hour) {
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// The line under the greeting changes with the hour, so the app does not
/// greet a 6am start the same way it greets an 11pm one.
String _encouragement(int hour) {
  if (hour < 12) return 'A clean slate. Let’s keep a few.';
  if (hour < 17) return 'Future you is proud of today.';
  if (hour < 22) return 'Wind down. Whatever’s left, I’ll hold.';
  return 'Late one. I’ll still be here tomorrow.';
}
