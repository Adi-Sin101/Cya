import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A circular progress ring showing `completed/total`, painted once via a
/// [CustomPainter] and isolated behind a [RepaintBoundary] (PRD §9.1).
class CompletionRing extends StatelessWidget {
  const CompletionRing({
    super.key,
    required this.completed,
    required this.total,
    this.size = 74,
    this.strokeWidth = 8,
    this.trackColor,
    this.progressColors,
    this.textColor,
  });

  final int completed;
  final int total;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final List<Color>? progressColors;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total <= 0
        ? 0.0
        : (completed / total).clamp(0.0, 1.0).toDouble();
    final text = textColor ?? theme.colorScheme.onSurface;
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: progress,
            trackColor: trackColor ?? theme.colorScheme.surfaceContainerHighest,
            progressColors: progressColors ?? AppColors.brandGradient,
            strokeWidth: strokeWidth,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$completed/$total',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'done',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: text.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColors,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final List<Color> progressColors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;
    const start = -math.pi / 2;
    final colors = progressColors.length == 1
        ? <Color>[progressColors.first, progressColors.first]
        : progressColors;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: colors,
        transform: const GradientRotation(start),
      ).createShader(rect);
    canvas.drawArc(rect, start, 2 * math.pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
