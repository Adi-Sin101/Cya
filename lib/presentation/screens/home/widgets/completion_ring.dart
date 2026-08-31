import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';

/// A circular progress ring showing `completed/total`, painted by a
/// [CustomPainter] inside a [RepaintBoundary] (PRD §9.1).
///
/// The arc sweeps to its new value instead of jumping. Ticking a promise off
/// is the app's core reward moment; watching the ring close the gap is most of
/// what makes it feel like one.
class CompletionRing extends StatelessWidget {
  const CompletionRing({
    super.key,
    required this.completed,
    required this.total,
    this.size = 74,
    this.strokeWidth = 9,
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
    final complete = total > 0 && completed >= total;

    return Semantics(
      label: '$completed of $total promises done today',
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: AppMotion.of(context, AppMotion.slow),
              curve: AppMotion.enter,
              builder: (context, value, child) => CustomPaint(
                painter: _RingPainter(
                  progress: value,
                  trackColor:
                      trackColor ?? theme.colorScheme.surfaceContainerHighest,
                  progressColors: progressColors ?? AppColors.brandGradient,
                  strokeWidth: strokeWidth,
                ),
                child: child,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // The whole point of "all done" is that it stops being a
                    // fraction. A tick reads as finished; "8/8" reads as maths.
                    if (complete)
                      Icon(Icons.check_rounded, size: size * 0.36, color: text)
                    else
                      Text(
                        '$completed/$total',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    Text(
                      complete ? 'all done' : 'done',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: text.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
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

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = trackColor,
    );

    if (progress <= 0) return;
    const start = -math.pi / 2;
    final colors = progressColors.length == 1
        ? <Color>[progressColors.first, progressColors.first]
        : progressColors;
    canvas.drawArc(
      rect,
      start,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: colors,
          transform: const GradientRotation(start),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
