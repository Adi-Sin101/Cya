import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/routine.dart';

/// A path through the person's actual selections, never inferred activity.
class RhythmDayPath extends StatelessWidget {
  const RhythmDayPath({super.key, required this.items});
  final List<RoutineOccurrence> items;
  @override
  Widget build(BuildContext context) {
    final done = items.where((i) => i.state == 'completed').length;
    return Semantics(
      label: '${items.length} routines selected, $done completed',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: ColoredBox(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkMintWash
              : AppColors.lightMintWash,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items.isEmpty
                      ? 'A day with room.'
                      : 'One step, then the next.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  items.isEmpty
                      ? 'Choose what belongs here.'
                      : '$done done · ${items.length} chosen',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                ExcludeSemantics(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: AppMotion.of(context, AppMotion.slow),
                    curve: AppMotion.enter,
                    builder: (context, t, _) => SizedBox(
                      height: 126,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _DayPathPainter(
                          items,
                          t,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (items.length > 5)
                  Text(
                    '+${items.length - 5} more in your plan',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayPathPainter extends CustomPainter {
  _DayPathPainter(this.items, this.reveal, this.ink, this.onInk);
  final List<RoutineOccurrence> items;
  final double reveal;
  final Color ink;
  final Color onInk;
  @override
  void paint(Canvas canvas, Size size) {
    final count = items.isEmpty ? 3 : math.min(5, items.length);
    final points = List.generate(
      count,
      (i) => Offset(
        20 + (size.width - 40) * (count == 1 ? 0.5 : i / (count - 1)),
        58 + math.sin(i * 1.8) * 22,
      ),
    );
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1], b = points[i];
      path.cubicTo(
        (a.dx + b.dx) / 2,
        a.dy,
        (a.dx + b.dx) / 2,
        b.dy,
        b.dx,
        b.dy,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = ink.withValues(alpha: .12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * reveal),
        Paint()
          ..color = ink.withValues(alpha: .4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
    for (var i = 0; i < points.length; i++) {
      final point = points[i],
          done = items.isNotEmpty && items[i].state == 'completed';
      canvas.drawCircle(
        point,
        18,
        Paint()..color = done ? ink : ink.withValues(alpha: .12),
      );
      canvas.drawCircle(
        point,
        12,
        Paint()..color = done ? ink : AppColors.mint.withValues(alpha: .65),
      );
      if (done) {
        final check = Path()
          ..moveTo(point.dx - 6, point.dy)
          ..lineTo(point.dx - 1, point.dy + 5)
          ..lineTo(point.dx + 7, point.dy - 5);
        canvas.drawPath(
          check,
          Paint()
            ..color = onInk
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      } else {
        final label = TextPainter(
          text: TextSpan(
            text: items.isEmpty ? '·' : '${i + 1}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.fontFamily,
              color: AppColors.deepInk,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        label.paint(canvas, point - Offset(label.width / 2, label.height / 2));
      }
      // Small leaves belong to the path, without an always-running animation.
      if (i.isEven) {
        canvas.save();
        canvas.translate(point.dx + 15, point.dy - 30);
        canvas.rotate(-.6);
        canvas.drawOval(
          const Rect.fromLTWH(0, 0, 10, 19),
          Paint()..color = ink.withValues(alpha: .25),
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_DayPathPainter old) =>
      old.items != items ||
      old.reveal != reveal ||
      old.ink != ink ||
      old.onInk != onInk;
}

class RoutineVisualCard extends StatelessWidget {
  const RoutineVisualCard({
    super.key,
    required this.item,
    required this.index,
    required this.onAction,
  });
  final RoutineOccurrence item;
  final int index;
  final ValueChanged<String> onAction;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), done = item.state == 'completed';
    final tone = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 12),
            child: AnimatedContainer(
              duration: AppMotion.of(context, AppMotion.quick),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? tone : theme.colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: done
                    ? Icon(
                        Icons.check_rounded,
                        size: 19,
                        color: theme.colorScheme.onPrimary,
                      )
                    : Text('$index', style: theme.textTheme.labelLarge),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: done
                  ? tone.withValues(alpha: .09)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 8, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              item.title,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Routine options',
                          onSelected: onAction,
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'adjust',
                              child: Text('Make it lighter / change time'),
                            ),
                            const PopupMenuItem(
                              value: 'defer',
                              child: Text('Move to another day'),
                            ),
                            if (!done)
                              const PopupMenuItem(
                                value: 'skipped',
                                child: Text('Skip this occurrence'),
                              ),
                            const PopupMenuItem(
                              value: 'today',
                              child: Text('Plan for the selected day'),
                            ),
                            const PopupMenuItem(
                              value: 'pause',
                              child: Text('Defer and pause routine'),
                            ),
                            const PopupMenuItem(
                              value: 'up',
                              child: Text('Move earlier'),
                            ),
                            const PopupMenuItem(
                              value: 'down',
                              child: Text('Move later'),
                            ),
                            const PopupMenuItem(
                              value: 'history',
                              child: Text('Occurrence history'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        _Tag(
                          icon: done
                              ? Icons.check_circle_outline
                              : Icons.schedule_rounded,
                          label: done
                              ? 'Done'
                              : item.state == 'skipped'
                              ? 'Skipped'
                              : item.state == 'deferred'
                              ? 'Moved'
                              : item.start == null
                              ? 'Flexible'
                              : '${(item.start! ~/ 60).toString().padLeft(2, '0')}:${(item.start! % 60).toString().padLeft(2, '0')}',
                        ),
                        if (item.steps.isNotEmpty)
                          _Tag(
                            icon: Icons.format_list_bulleted_rounded,
                            label: '${item.steps.length} steps',
                          ),
                      ],
                    ),
                    if (item.open) ...[
                      if (item.steps.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12, right: 12),
                          child: Text(
                            item.steps.first,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: () => onAction('focus'),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Focus'),
                          ),
                          IconButton.filledTonal(
                            onPressed: () => onAction('completed'),
                            tooltip: 'Mark completed',
                            icon: const Icon(Icons.check_rounded),
                          ),
                        ],
                      ),
                    ],
                    if (!item.open && !done)
                      TextButton.icon(
                        onPressed: () => onAction('today'),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Choose again'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 5),
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}

/// Actual recorded outcomes, with a text equivalent for assistive technology.
class ReviewOutcomeChart extends StatelessWidget {
  const ReviewOutcomeChart({super.key, required this.states});
  final Map<String, int> states;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context),
        total = states.values.fold(0, (a, b) => a + b);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.outline,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: states.entries.map((e) => '${e.key}: ${e.value}').join(', '),
          child: ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 30,
                child: Row(
                  children: [
                    if (total == 0)
                      Expanded(
                        child: ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    for (var i = 0; i < states.length; i++)
                      if (states.values.elementAt(i) > 0)
                        Expanded(
                          flex: states.values.elementAt(i),
                          child: ColoredBox(color: colors[i % colors.length]),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            for (var i = 0; i < states.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors[i % colors.length],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${states.keys.elementAt(i)}: ${states.values.elementAt(i)}',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
