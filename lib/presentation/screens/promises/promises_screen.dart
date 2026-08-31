import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/result.dart';
import '../../../core/router/route_paths.dart';
import '../../../domain/entities/intention.dart';
import '../../../domain/enums/intention_status.dart';
import '../../providers/intention_providers.dart';
import '../home/widgets/promise_tile.dart';

/// The full promise list with on-device search and status filters
/// (PRD §6.4, §8.2).
class PromisesScreen extends ConsumerStatefulWidget {
  const PromisesScreen({super.key});

  @override
  ConsumerState<PromisesScreen> createState() => _PromisesScreenState();
}

enum _Filter {
  open('Open'),
  done('Done'),
  all('All');

  const _Filter(this.label);

  final String label;
}

class _PromisesScreenState extends ConsumerState<PromisesScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  _Filter _filter = _Filter.open;

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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Promises', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 12),
                SearchBar(
                  controller: _search,
                  hintText: 'Search everything you saved',
                  leading: const Icon(Icons.search_rounded),
                  trailing: <Widget>[
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
                  ],
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    for (final filter in _Filter.values) ...<Widget>[
                      ChoiceChip(
                        label: Text(filter.label),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
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
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final promise = visible[index];
                    return PromiseTile(
                      key: ValueKey<int>(promise.id),
                      promise: promise,
                      now: now,
                      onToggle: () => _toggle(promise.id),
                      onTap: () =>
                          context.push(RoutePaths.promiseDetail(promise.id)),
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

  bool _matchesFilter(Intention promise) => switch (_filter) {
    _Filter.open => promise.status.isPending,
    _Filter.done => promise.status == IntentionStatus.resolved,
    _Filter.all => true,
  };

  Future<void> _toggle(int id) async {
    final result = await ref.read(resolveIntentionProvider).toggle(id);
    if (!mounted) return;
    if (result.errorOrNull case final AppError error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.searching, required this.filter});

  final bool searching;
  final _Filter filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (emoji, title, body) = searching
        ? ('🔍', 'Nothing matches that', 'Try a different word.')
        : switch (filter) {
            _Filter.done => (
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
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
