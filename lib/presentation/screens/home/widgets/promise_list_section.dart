import 'package:flutter/material.dart';

import '../../../../domain/entities/intention.dart';
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
            Text("Today's Promises", style: theme.textTheme.titleLarge),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'See all',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (promises.isEmpty)
          const _TodayEmptyState()
        else
          for (var i = 0; i < promises.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 10),
            PromiseTile(
              key: ValueKey<int>(promises[i].id),
              promise: promises[i],
              now: now,
              onToggle: () => onToggle(promises[i].id),
              onTap: onOpen == null ? null : () => onOpen!(promises[i].id),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          const Text('🦫', style: TextStyle(fontSize: 34)),
          const SizedBox(height: 10),
          Text(
            'Nothing due today',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "Share something to Cya! and I'll bring it back when it matters.",
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
