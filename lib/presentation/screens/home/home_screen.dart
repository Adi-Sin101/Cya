import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/result.dart';
import '../../../core/router/route_paths.dart';
import '../../../domain/entities/intention.dart';
import '../../providers/intention_providers.dart';
import '../../providers/settings_providers.dart';
import 'widgets/home_greeting_header.dart';
import 'widgets/memory_garden_preview.dart';
import 'widgets/promise_list_section.dart';
import 'widgets/today_card.dart';
import 'widgets/week_stats_section.dart';

/// The Home screen (PRD §8.2), reactive over the local store (§3.3).
///
/// Every section is its own `Consumer` so a write only rebuilds the part it
/// touches — the greeting does not repaint because a promise was ticked
/// (PRD §9.1).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
        children: const <Widget>[
          _GreetingSection(),
          SizedBox(height: 20),
          _TodaySection(),
          SizedBox(height: 24),
          _PromisesSection(),
          SizedBox(height: 24),
          _GardenSection(),
          SizedBox(height: 16),
          _WeekSection(),
        ],
      ),
    );
  }
}

class _GreetingSection extends ConsumerWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HomeGreetingHeader(
      userName: ref.watch(displayNameProvider).valueOrNull,
      level: ref.watch(userLevelProvider),
      now: ref.watch(clockProvider)(),
    );
  }
}

class _TodaySection extends ConsumerWidget {
  const _TodaySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promises =
        ref.watch(todayIntentionsProvider).valueOrNull ?? const <Intention>[];
    return TodayCard(
      total: promises.length,
      completed: promises.where((p) => p.isResolved).length,
    );
  }
}

class _PromisesSection extends ConsumerWidget {
  const _PromisesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promises = ref.watch(todayIntentionsProvider);
    return promises.when(
      loading: () => const _SectionLoading(),
      error: (error, _) => _SectionError(message: '$error'),
      data: (items) => PromiseListSection(
        promises: items,
        now: ref.watch(clockProvider)(),
        onToggle: (id) => _toggle(context, ref, id),
        onOpen: (id) => context.push(RoutePaths.promiseDetail(id)),
        onSeeAll: () => context.go(RoutePaths.promises),
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, int id) async {
    final result = await ref.read(resolveIntentionProvider).toggle(id);
    if (!context.mounted) return;
    if (result.errorOrNull case final AppError error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _GardenSection extends ConsumerWidget {
  const _GardenSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.go(RoutePaths.garden),
      child: MemoryGardenPreview(garden: ref.watch(gardenSummaryProvider)),
    );
  }
}

class _WeekSection extends ConsumerWidget {
  const _WeekSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WeekStatsSection(stats: ref.watch(weekStatsProvider));
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "Couldn't load your promises.\n$message",
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
    );
  }
}
