import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/result.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/intention.dart';
import '../../../domain/projections/garden_projection.dart';
import '../../providers/intention_providers.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/motion/entrance.dart';
import '../../widgets/motion/reward_burst.dart';
import 'widgets/home_greeting_header.dart';
import 'widgets/promise_list_section.dart';
import 'widgets/reminder_health_banner.dart';
import 'widgets/today_card.dart';
import 'widgets/week_card.dart';

/// The Home screen (PRD §8.2), reactive over the local store (§3.3).
///
/// Four blocks, in the order a glance wants them: who you are, what today is,
/// what today holds, how the week is going. Every section is its own
/// `Consumer` so a write only rebuilds the part it touches — the greeting does
/// not repaint because a promise was ticked (PRD §9.1).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          AppSpacing.navClearance,
        ),
        children: <Widget>[
          const Entrance(child: _GreetingSection()),
          const SizedBox(height: AppSpacing.xl),
          const ReminderHealthBanner(),
          const Entrance(
            delay: Duration(milliseconds: 70),
            child: _TodaySection(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const _PromisesSection(),
          const SizedBox(height: AppSpacing.xxl),
          const Entrance(
            delay: Duration(milliseconds: 140),
            child: _WeekSection(),
          ),
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
    // Read before the write, so we know which direction the toggle went and
    // can celebrate only the direction worth celebrating.
    final before = ref.read(todayIntentionsProvider).valueOrNull;
    final wasResolved =
        before?.where((p) => p.id == id).firstOrNull?.isResolved ?? false;

    final result = await ref.read(resolveIntentionProvider).toggle(id);
    if (!context.mounted) return;

    if (result.errorOrNull case final AppError error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }
    // Keeping a promise is the moment the whole product exists for. Undoing
    // one is not (PRD §8.3, ADR-007).
    if (!wasResolved) showRewardBurst(context, seed: id);
  }
}

class _WeekSection extends ConsumerWidget {
  const _WeekSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(gardenSceneProvider);
    return WeekCard(
      stats: ref.watch(weekStatsProvider),
      plants: scene.beds.isEmpty
          ? const <GardenPlant>[]
          : scene.beds.last.plants,
      now: ref.watch(clockProvider)(),
      onTap: () => context.go(RoutePaths.garden),
    );
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
