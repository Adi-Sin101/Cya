import 'package:flutter/material.dart';

import 'completion_ring.dart';

/// The hero "Today" card: promise count + completion ring on the brand
/// gradient (PRD §8.2).
class TodayCard extends StatelessWidget {
  const TodayCard({super.key, required this.total, required this.completed});

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = (total - completed).clamp(0, total);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF2E705B),
            Color(0xFF74B69D),
            Color(0xFFA7D7C5),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF2E705B).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  'Today',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$total promises',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completed completed · $remaining to go',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CompletionRing(
            completed: completed,
            total: total,
            size: 86,
            trackColor: Colors.white24,
            progressColors: const <Color>[Colors.white, Colors.white],
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
