import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/reminder_format.dart';
import '../../../domain/projections/garden_projection.dart';
import '../../providers/intention_providers.dart';
import 'widgets/garden_bed_painter.dart';

/// The Memory Garden (PRD §6.6, §8.2) — the emotional core of retention.
///
/// Every plant is a promise the user kept, projected from the event log
/// (ADR-002): the garden cannot disagree with the stats, because it is the same
/// truth drawn differently.
class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(gardenSceneProvider);
    final now = ref.watch(clockProvider)();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _GardenHeader(scene: scene)),
          if (scene.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyGarden(),
            )
          else
            SliverList.builder(
              // Newest bed first: this week's growth is what the user came for.
              itemCount: scene.beds.length,
              itemBuilder: (context, index) => _BedCard(
                bed: scene.beds[scene.beds.length - 1 - index],
                now: now,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 130)),
        ],
      ),
    );
  }
}

class _GardenHeader extends StatelessWidget {
  const _GardenHeader({required this.scene});

  final GardenScene scene;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Memory Garden', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            scene.isEmpty
                ? 'Every promise you keep grows something here.'
                : '${scene.totalGrowths} promises kept, and counting.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _GardenStat(
                  value: '${scene.thisWeekGrowths}',
                  label: 'this week',
                  emoji: '🌱',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GardenStat(
                  value: '${scene.streakDays}',
                  label: scene.streakDays == 1 ? 'day streak' : 'day streak',
                  emoji: '🔥',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GardenStat(
                  value: '${scene.totalGrowths}',
                  label: 'all time',
                  emoji: '🪴',
                ),
              ),
            ],
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
    required this.emoji,
  });

  final String value;
  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cya.surface2),
      ),
      child: Column(
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// One week's bed. The plants animate in once, then the scene is static —
/// nothing repaints until the garden actually changes (PRD §9.1).
class _BedCard extends StatefulWidget {
  const _BedCard({required this.bed, required this.now});

  final GardenBed bed;
  final DateTime now;

  @override
  State<_BedCard> createState() => _BedCardState();
}

class _BedCardState extends State<_BedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plants = widget.bed.plants;
    final rows = (plants.length / 9).ceil().clamp(1, 6);
    // Reduced motion: plants are simply there, fully grown (PRD §8.3).
    final calm = MediaQuery.disableAnimationsOf(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              const Color(0xFFA7D7C5).withValues(alpha: 0.35),
              const Color(0xFF74B69D).withValues(alpha: 0.18),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _weekLabel(widget.bed.weekStart, widget.now),
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  plants.length == 1 ? '1 growth' : '${plants.length} growths',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  size: Size(double.infinity, 60.0 + (rows - 1) * 26),
                  painter: GardenBedPainter(
                    plants: plants,
                    soil: const Color(0xFF8D6E4F).withValues(alpha: 0.45),
                    palette: const <Color>[
                      Color(0xFF2E705B),
                      Color(0xFF74B69D),
                      Color(0xFFA7D7C5),
                      Color(0xFF16A34A),
                      Color(0xFF4D9A7C),
                    ],
                    growthScale: calm
                        ? 1
                        : Curves.easeOutBack
                              .transform(_controller.value)
                              .clamp(0.0, 1.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGarden extends StatelessWidget {
  const _EmptyGarden();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('🪴', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 14),
            Text(
              'Bare soil, for now',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Keep a promise and the first thing grows here. '
              'Nothing you capture is wasted.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
