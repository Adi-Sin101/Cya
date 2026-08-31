import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/result.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../domain/entities/intention.dart';
import '../../../domain/enums/intention_status.dart';
import '../../../domain/enums/promise_category.dart';
import '../../providers/intention_providers.dart';
import '../../widgets/motion/entrance.dart';
import '../../widgets/motion/reward_burst.dart';
import '../home/widgets/promise_tile.dart';
import 'widgets/promise_filter_bar.dart';

/// The full promise list with on-device search and status filters
/// (PRD §6.4, §8.2).
class PromisesScreen extends ConsumerStatefulWidget {
  const PromisesScreen({super.key});

  @override
  ConsumerState<PromisesScreen> createState() => _PromisesScreenState();
}

class _PromisesScreenState extends ConsumerState<PromisesScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  PromiseFilter _filter = PromiseFilter.open;
  PromiseCategory? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final results = _query.trim().isEmpty
        ? ref.watch(allIntentionsProvider)
        : ref.watch(intentionSearchProvider(_query));

    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Promises', style: theme.textTheme.displaySmall),
                const SizedBox(height: AppSpacing.lg),
                SearchBar(
                  controller: _search,
                  hintText: 'Search everything you saved',
                  elevation: const WidgetStatePropertyAll<double>(0),
                  backgroundColor: WidgetStatePropertyAll<Color>(
                    context.cyaColors.surface2,
                  ),
                  textStyle: WidgetStatePropertyAll<TextStyle?>(
                    theme.textTheme.bodyLarge,
                  ),
                  hintStyle: WidgetStatePropertyAll<TextStyle?>(
                    theme.textTheme.bodyLarge?.copyWith(
                      color: context.cyaColors.textSecondary,
                    ),
                  ),
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  ),
                  shape: WidgetStatePropertyAll<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  leading: Icon(
                    Icons.search_rounded,
                    color: context.cyaColors.textSecondary,
                  ),
                  trailing: <Widget>[
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
                  ],
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: AppSpacing.md),
                PromiseFilterBar(
                  filter: _filter,
                  category: _category,
                  onFilterChanged: (value) => setState(() => _filter = value),
                  onCategoryChanged: (value) =>
                      setState(() => _category = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: results.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (error, _) => Center(child: Text('$error')),
              data: (items) {
                final visible = items.where(_matchesFilter).toList();
                if (visible.isEmpty) {
                  return _EmptyList(
                    searching: _query.trim().isNotEmpty,
                    filter: _filter,
                    category: _category,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.xs,
                    AppSpacing.page,
                    AppSpacing.navClearance,
                  ),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final promise = visible[index];
                    return Entrance(
                      // Only the first screenful staggers; scrolling further
                      // should feel instant, not choreographed.
                      delay: index < 7
                          ? Duration(milliseconds: 45 * index)
                          : Duration.zero,
                      child: PromiseTile(
                        key: ValueKey<int>(promise.id),
                        promise: promise,
                        now: now,
                        onToggle: () => _toggle(promise),
                        onTap: () =>
                            context.push(RoutePaths.promiseDetail(promise.id)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesFilter(Intention promise) {
    if (_category != null && promise.category != _category!.wire) return false;
    return switch (_filter) {
      PromiseFilter.open => promise.status.isPending,
      PromiseFilter.done => promise.status == IntentionStatus.resolved,
      PromiseFilter.all => true,
    };
  }

  Future<void> _toggle(Intention promise) async {
    final wasResolved = promise.isResolved;
    final result = await ref.read(resolveIntentionProvider).toggle(promise.id);
    if (!mounted) return;
    if (result.errorOrNull case final AppError error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }
    if (!wasResolved) showRewardBurst(context, seed: promise.id);
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({
    required this.searching,
    required this.filter,
    this.category,
  });

  final bool searching;
  final PromiseFilter filter;
  final PromiseCategory? category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (emoji, title, body) = category != null
        ? (
            '🗂️',
            'Nothing in ${category!.label}',
            'Promises get a category from their detail screen.',
          )
        : searching
        ? ('🔍', 'Nothing matches that', 'Try a different word.')
        : switch (filter) {
            PromiseFilter.done => (
              '🌱',
              'Nothing finished yet',
              'Tick a promise off and it grows in your garden.',
            ),
            _ => (
              '🦫',
              'No promises yet',
              "Share something to Cya! and I'll hold on to it.",
            ),
          };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.section),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
