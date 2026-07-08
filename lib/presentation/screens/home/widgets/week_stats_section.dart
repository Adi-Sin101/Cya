import 'package:flutter/material.dart';

import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../domain/models/week_stats.dart';
import 'stat_tile.dart';

/// "This Week" stats: a trend sparkline + Captured / Completed / Success Rate
/// (PRD §6.6, §8.2).
class WeekStatsSection extends StatelessWidget {
  const WeekStatsSection({super.key, required this.stats});

  final WeekStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    final rate = (stats.successRate * 100).round();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cya.surface2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('This Week', style: theme.textTheme.titleLarge),
              Row(
                children: <Widget>[
                  Icon(Icons.trending_up_rounded, size: 16, color: cya.success),
                  const SizedBox(width: 4),
                  Text(
                    'On a roll',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cya.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 44,
            width: double.infinity,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _SparklinePainter(
                  points: stats.trend,
                  color: theme.colorScheme.primary,
                  fill: theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: StatTile(
                  value: '${stats.captured}',
                  label: 'Captured',
                  color: theme.colorScheme.primary,
                ),
              ),
              Expanded(
                child: StatTile(
                  value: '${stats.completed}',
                  label: 'Completed',
                  color: cya.success,
                ),
              ),
              Expanded(
                child: StatTile(
                  value: '$rate%',
                  label: 'Success Rate',
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.points,
    required this.color,
    required this.fill,
  });

  final List<double> points;
  final Color color;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final dx = size.width / (points.length - 1);
    Offset at(int i) =>
        Offset(dx * i, size.height - points[i].clamp(0.0, 1.0) * size.height);

    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < points.length; i++) {
      final prev = at(i - 1);
      final curr = at(i);
      final midX = (prev.dx + curr.dx) / 2;
      line.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas
      ..drawPath(area, Paint()..color = fill)
      ..drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
