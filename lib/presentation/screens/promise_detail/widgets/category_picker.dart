import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../core/utils/cya_haptics.dart';
import '../../../../domain/enums/promise_category.dart';

/// Category for a promise (PRD §6.4).
///
/// Seven chips laid out inline took three rows and dominated the detail
/// screen, competing with the three actions that actually close the loop
/// (§3.4). It is now one row: what the category *is*, and a tap to change it.
/// Choosing still costs one tap from the sheet, and clearing is one more.
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
    final cya = context.cyaColors;
    final category = selected;

    return Material(
      color: cya.surface2,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () async {
          CyaHaptics.tap(context);
          final picked = await _showPicker(context, category);
          if (picked != null) onChanged(picked.value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md + 2,
          ),
          child: Row(
            children: <Widget>[
              AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.quick),
                child: Icon(
                  category == null
                      ? Icons.label_outline_rounded
                      : categoryIcon(category),
                  key: ValueKey<String?>(category?.wire),
                  size: 22,
                  color: category == null
                      ? cya.textSecondary
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  category?.label ?? 'Add a category',
                  style: category == null
                      ? theme.textTheme.titleSmall?.copyWith(
                          color: cya.textSecondary,
                        )
                      : theme.textTheme.titleSmall,
                ),
              ),
              Icon(Icons.expand_more_rounded, color: cya.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Distinguishes "dismissed the sheet" from "chose to clear the category".
class _Choice {
  const _Choice(this.value);

  final PromiseCategory? value;
}

Future<_Choice?> _showPicker(BuildContext context, PromiseCategory? selected) {
  return showModalBottomSheet<_Choice>(
    context: context,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'What kind of thing is this?',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm + 2,
                runSpacing: AppSpacing.sm + 2,
                children: <Widget>[
                  for (final category in PromiseCategory.values)
                    ChoiceChip(
                      label: Text(category.label),
                      avatar: Icon(categoryIcon(category), size: 18),
                      selected: selected == category,
                      onSelected: (_) => Navigator.of(sheetContext).pop(
                        // Re-picking the current category clears it: a
                        // category the user regrets should be as cheap to
                        // remove as it was to add.
                        _Choice(selected == category ? null : category),
                      ),
                    ),
                  if (selected != null)
                    ActionChip(
                      avatar: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('No category'),
                      onPressed: () =>
                          Navigator.of(sheetContext).pop(const _Choice(null)),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
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
