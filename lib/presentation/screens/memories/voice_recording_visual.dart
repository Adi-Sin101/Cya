import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_motion.dart';

/// Actual elapsed recording time, never simulated sound amplitude.
class VoiceRecordingVisual extends StatelessWidget {
  const VoiceRecordingVisual({
    super.key,
    required this.seconds,
    required this.recording,
    required this.ready,
  });
  final int seconds;
  final bool recording, ready;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = theme.colorScheme;
    final clock =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Semantics(
      label: recording
          ? 'Recording, $seconds seconds elapsed'
          : ready
          ? 'Recording ready, $seconds seconds'
          : 'Microphone is off',
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: (seconds / 300).clamp(0, 1)),
              duration: AppMotion.of(context, AppMotion.quick),
              builder: (context, progress, _) => CustomPaint(
                painter: _ElapsedRing(
                  progress,
                  colors.primary,
                  colors.secondaryContainer,
                ),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.secondaryContainer,
                    ),
                    child: Icon(
                      ready ? Icons.check_rounded : Icons.mic_rounded,
                      size: 48,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            clock,
            style: theme.textTheme.displayMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recording
                ? 'Your voice, being kept.'
                : ready
                ? 'A moment worth keeping.'
                : 'Ready when you are',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            recording
                ? 'Up to 5 minutes · Stop whenever you’re ready'
                : ready
                ? 'Listen back, then save your original.'
                : 'Tap below to begin. Nothing is recording yet.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ElapsedRing extends CustomPainter {
  _ElapsedRing(this.progress, this.ink, this.track);
  final double progress;
  final Color ink, track;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(8);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        paint..color = ink,
      );
    }
  }

  @override
  bool shouldRepaint(_ElapsedRing old) =>
      old.progress != progress || old.ink != ink || old.track != track;
}
