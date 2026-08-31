import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../domain/entities/intention.dart';
import '../../../widgets/motion/entrance.dart';
import 'promise_tile.dart';

/// "Today's Promises" header + the list of promise tiles (PRD §8.2).
class PromiseListSection extends StatelessWidget {
  const PromiseListSection({
    super.key,
    required this.promises,
    required this.now,
    required this.onToggle,
    this.onOpen,
    this.onSeeAll,
  });

  final List<Intention> promises;
  final DateTime now;
  final ValueChanged<int> onToggle;
  final ValueChanged<int>? onOpen;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Today's promises", style: theme.textTheme.titleLarge),
            if (onSeeAll != null && promises.isNotEmpty)
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                child: const Text('See all'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (promises.isEmpty)
          const _TodayEmptyState()
        else
          // Rows arrive top-down. The stagger is what turns "the list
          // appeared" into "the list was dealt out".
          ...Entrance.staggered(<Widget>[
            for (var i = 0; i < promises.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.md),
                child: PromiseTile(
                  key: ValueKey<int>(promises[i].id),
                  promise: promises[i],
                  now: now,
                  onToggle: () => onToggle(promises[i].id),
                  onTap: onOpen == null ? null : () => onOpen!(promises[i].id),
                ),
              ),
          ]),
      ],
    );
  }
}

/// Nothing due today is a good day, not an error — say so (PRD §8.3: the
/// mascot shows up in empathy moments).
class _TodayEmptyState extends StatelessWidget {
  const _TodayEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxl + 4,
        horizontal: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          const Text('🦫', style: TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nothing due today',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            "Share something to Cya! and I'll bring it back when it matters.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.cyaColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
