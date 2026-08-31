import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../core/utils/cya_haptics.dart';
import '../../../../domain/enums/promise_category.dart';
import '../../promise_detail/widgets/category_picker.dart' show categoryIcon;

/// The three status filters on the Promises tab.
enum PromiseFilter {
  open('Open'),
  done('Done'),
  all('All');

  const PromiseFilter(this.label);

  final String label;
}

/// Status segments plus a category button (PRD §6.4, §8.2).
///
/// This replaces three stacked rows of chips — three status chips over seven
/// category chips over a search field — which pushed the first actual promise
/// most of a screen down and asked the user to make two filing decisions
/// before reading anything. Status is the filter people use constantly, so it
/// stays visible; category is occasional, so it collapses to one button that
/// shows a dot when it is doing something.
class PromiseFilterBar extends StatelessWidget {
  const PromiseFilterBar({
    super.key,
    required this.filter,
    required this.category,
    required this.onFilterChanged,
    required this.onCategoryChanged,
  });

  final PromiseFilter filter;
  final PromiseCategory? category;
  final ValueChanged<PromiseFilter> onFilterChanged;
  final ValueChanged<PromiseCategory?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final cya = context.cyaColors;

    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: cya.surface2,
              borderRadius: BorderRadius.circular(AppRadius.sm + 2),
            ),
            child: Row(
              children: <Widget>[
                for (final value in PromiseFilter.values)
                  Expanded(
                    child: _Segment(
                      label: value.label,
                      selected: filter == value,
                      onTap: () {
                        if (filter == value) return;
                        CyaHaptics.selection(context);
                        onFilterChanged(value);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _CategoryButton(
          category: category,
          onTap: () async {
            CyaHaptics.tap(context);
            final picked = await _showCategorySheet(context, category);
            // `null` for "no change" is indistinguishable from `null` for
            // "clear", so the sheet returns a wrapper and only a real result
            // is applied.
            if (picked != null) onCategoryChanged(picked.value);
          },
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.quick),
          curve: AppMotion.standard,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: selected ? cyaShadow(context, elevation: 0.4) : null,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected
                  ? theme.colorScheme.onSurface
                  : context.cyaColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({required this.category, required this.onTap});

  final PromiseCategory? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = category != null;
    return Semantics(
      button: true,
      label: active
          ? 'Filtering by ${category!.label}. Change category filter'
          : 'Filter by category',
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: AppTouch.minTarget + 2,
            height: AppTouch.minTarget + 2,
            decoration: BoxDecoration(
              color: active
                  ? theme.colorScheme.secondaryContainer
                  : context.cyaColors.surface2,
              borderRadius: BorderRadius.circular(AppRadius.sm + 2),
            ),
            child: Icon(
              active ? categoryIcon(category!) : Icons.tune_rounded,
              color: active
                  ? theme.colorScheme.primary
                  : context.cyaColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrapper distinguishing "the user chose nothing" from "the user chose to
/// clear the filter".
class _Choice {
  const _Choice(this.value);

  final PromiseCategory? value;
}

Future<_Choice?> _showCategorySheet(
  BuildContext context,
  PromiseCategory? selected,
) {
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
              Text('Show only', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm + 2,
                runSpacing: AppSpacing.sm + 2,
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('Everything'),
                    selected: selected == null,
                    onSelected: (_) =>
                        Navigator.of(sheetContext).pop(const _Choice(null)),
                  ),
                  for (final category in PromiseCategory.values)
                    ChoiceChip(
                      label: Text(category.label),
                      avatar: Icon(categoryIcon(category), size: 18),
                      selected: selected == category,
                      onSelected: (_) =>
                          Navigator.of(sheetContext).pop(_Choice(category)),
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
