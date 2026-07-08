import 'package:flutter/material.dart';

import '../../../../domain/models/promise.dart';
import 'promise_tile.dart';

/// "Today's Promises" header + the list of promise tiles (PRD §8.2).
class PromiseListSection extends StatelessWidget {
  const PromiseListSection({
    super.key,
    required this.promises,
    required this.onToggle,
  });

  final List<Promise> promises;
  final ValueChanged<String> onToggle;

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
            Text(
              'See all',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < promises.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 10),
          PromiseTile(
            promise: promises[i],
            onToggle: () => onToggle(promises[i].id),
          ),
        ],
      ],
    );
  }
}
