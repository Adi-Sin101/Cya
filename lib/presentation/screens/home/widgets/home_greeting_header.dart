import 'package:flutter/material.dart';

import '../../../../domain/models/user_level.dart';
import 'level_badge.dart';

/// Time-aware greeting + level badge at the top of Home (PRD §8.2).
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
          name == null || name.isEmpty ? '$greeting 👋' : '$greeting, $name 👋',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Future you is proud of today.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        LevelBadge(level: level),
      ],
    );
  }
}

String _greeting(int hour) {
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}
