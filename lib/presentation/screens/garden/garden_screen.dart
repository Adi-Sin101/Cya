import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/reminder_format.dart';
import '../../../domain/projections/garden_projection.dart';
import '../../providers/intention_providers.dart';
import '../../widgets/motion/animated_counter.dart';
import '../../widgets/motion/entrance.dart';
import 'widgets/garden_scene_view.dart';

/// The Memory Garden (PRD §6.6, §8.2) — the emotional core of retention.
///
/// Every plant is a promise the user kept, projected from the event log
/// (ADR-002): the garden cannot disagree with the stats, because it is the same
/// truth drawn differently.
///
/// The screen has exactly one focal point. This week's growth is a full,
/// living landscape at the top; everything before it is a quiet strip of soil
/// in a scrolling history. Giving every week equal visual weight — which is
/// what a uniform list of cards does — buries the thing the user opened the
/// screen to see.
class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(gardenSceneProvider);
    final now = ref.watch(clockProvider)();

    // Newest first: this week's growth is what the user came for.
    final history = scene.beds.reversed.skip(1).toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Entrance(
              child: _GardenHero(scene: scene, now: now),
            ),
          ),
          if (scene.isEmpty)
            const SliverToBoxAdapter(child: _EmptyGarden())
          else ...<Widget>[
            SliverToBoxAdapter(
              child: Entrance(
                delay: const Duration(milliseconds: 90),
                child: _GardenStats(scene: scene),
              ),
            ),
            if (history.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.xxl,
                    AppSpacing.page,
                    AppSpacing.md,
                  ),
                  child: Text(
                    'Before this week',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            SliverList.builder(
              itemCount: history.length,
              itemBuilder: (context, index) =>
                  _HistoryBed(bed: history[index], now: now),
            ),
          ],
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.navClearance),
          ),
        ],
      ),
    );
  }
}

/// This week, as a place: a full landscape with the headline sitting in its
/// sky.
class _GardenHero extends StatelessWidget {
  const _GardenHero({required this.scene, required this.now});

  final GardenScene scene;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plants = scene.beds.isEmpty
        ? const <GardenPlant>[]
        : scene.beds.last.plants;
    // Text sits over the sky, so it takes its contrast from the sky, not from
    // the page background or the clock.
    final ink = gardenInkOn(context, now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: DecoratedBox(
          decoration: BoxDecoration(boxShadow: cyaShadow(context)),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: GardenSceneView(
                  plants: plants,
                  height: 260,
                  now: now,
                  plantScale: 1.7,
                ),
              ),
              // Reserves the Stack's height and carries the copy.
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: SizedBox(
                  height: 260 - AppSpacing.xl * 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Memory Garden',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      FadingText(
                        scene.isEmpty
                            ? 'Every promise you keep grows something here.'
                            : scene.thisWeekGrowths == 0
                            ? 'Nothing new this week — the garden is still yours.'
                            : scene.thisWeekGrowths == 1
                            ? 'One new growth this week.'
                            : '${scene.thisWeekGrowths} new growths this week.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: ink.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GardenStats extends StatelessWidget {
  const _GardenStats({required this.scene});

  final GardenScene scene;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _GardenStat(
              value: scene.totalGrowths,
              label: 'kept, all time',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _GardenStat(
              value: scene.streakDays,
              label: 'day streak',
              emphasise: scene.streakDays > 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _GardenStat extends StatelessWidget {
  const _GardenStat({
    required this.value,
    required this.label,
    this.emphasise = false,
  });

  final int value;
  final String label;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedCounter(
            value: value,
            style: theme.textTheme.displaySmall?.copyWith(
              color: emphasise ? cya.warningInk : theme.colorScheme.primary,
            ),
          ),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

/// One past week: a strip of soil, still, with its plants exactly as they grew.
class _HistoryBed extends StatelessWidget {
  const _HistoryBed({required this.bed, required this.now});

  final GardenBed bed;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plants = bed.plants;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _weekLabel(bed.weekStart, now),
                style: theme.textTheme.titleSmall,
              ),
              Text(
                plants.length == 1 ? '1 growth' : '${plants.length} growths',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: ColoredBox(
              color: context.cyaColors.surface2,
              child: LayoutBuilder(
                builder: (context, constraints) => GardenSceneView(
                  plants: plants,
                  height: gardenSceneHeight(
                    plants.length,
                    constraints.maxWidth,
                    base: 76,
                  ),
                  now: now,
                  showSky: false,
                  animateWind: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGarden extends StatelessWidget {
  const _EmptyGarden();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.section,
        AppSpacing.xxl,
        AppSpacing.section,
        0,
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Bare soil, for now',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Keep a promise and the first thing grows here. '
            'Nothing you capture is wasted.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: context.cyaColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

String _weekLabel(DateTime weekStart, DateTime now) {
  final thisWeek = now.subtract(Duration(days: now.weekday - DateTime.monday));
  final difference = DateTime(
    thisWeek.year,
    thisWeek.month,
    thisWeek.day,
  ).difference(weekStart).inDays;
  return switch (difference) {
    <= 0 => 'This week',
    <= 7 => 'Last week',
    _ => 'Week of ${formatDay(weekStart)}',
  };
}
