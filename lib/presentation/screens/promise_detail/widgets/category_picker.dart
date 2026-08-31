import 'package:flutter/material.dart';

import '../../../../domain/enums/promise_category.dart';

/// Category chips for a promise (PRD §6.4).
///
/// Inline rather than behind a menu: choosing a category should cost one tap or
/// none at all. Tapping the current category clears it — a category the user
/// regrets should be as easy to remove as it was to add.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PromiseCategory? selected;
  final ValueChanged<PromiseCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Category', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final category in PromiseCategory.values)
              ChoiceChip(
                label: Text(category.label),
                avatar: Icon(categoryIcon(category), size: 16),
                selected: selected == category,
                onSelected: (isSelected) =>
                    onChanged(isSelected ? category : null),
              ),
          ],
        ),
      ],
    );
  }
}

/// Shared iconography, so a category looks the same everywhere it appears.
IconData categoryIcon(PromiseCategory category) => switch (category) {
  PromiseCategory.reply => Icons.reply_rounded,
  PromiseCategory.read => Icons.menu_book_rounded,
  PromiseCategory.watch => Icons.play_circle_outline_rounded,
  PromiseCategory.buy => Icons.shopping_bag_outlined,
  PromiseCategory.work => Icons.work_outline_rounded,
  PromiseCategory.errand => Icons.directions_walk_rounded,
  PromiseCategory.idea => Icons.lightbulb_outline_rounded,
};
