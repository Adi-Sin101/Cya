import 'package:flutter/material.dart';

import '../../../../domain/models/garden_summary.dart';

/// The Memory Garden teaser card (PRD §6.6, §8.2).
class MemoryGardenPreview extends StatelessWidget {
  const MemoryGardenPreview({super.key, required this.garden});

  final GardenSummary garden;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const inkColor = Color(0xFF14532D);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFA7D7C5), Color(0xFF74B69D)],
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Memory Garden',
                  style: theme.textTheme.titleMedium?.copyWith(color: inkColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '${garden.newGrowthsThisWeek} new growths this week',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: inkColor.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('🌿', style: TextStyle(fontSize: 26)),
              Text('🌱', style: TextStyle(fontSize: 34)),
              Text('🪴', style: TextStyle(fontSize: 26)),
            ],
          ),
        ],
      ),
    );
  }
}
