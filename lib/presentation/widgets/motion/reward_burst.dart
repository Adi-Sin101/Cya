import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';

/// A burst of leaves and petals, painted once per frame by a single
/// [CustomPainter] (PRD §8.3, ADR-007).
///
/// §8.3 asks for Rive here. No mascot rig exists yet (§13.6), and a reward
/// moment is not worth blocking on art: this is ~40 particles integrated on the
/// CPU and drawn in one pass, which costs less than a Rive runtime plus asset
/// and needs no new dependency. Swap it out if and when the rig lands.
///
/// The particle field is generated once from a seed, so the burst is
/// deterministic and allocates nothing per frame.
class RewardBurst extends StatefulWidget {
  const RewardBurst({
    super.key,
    required this.seed,
    this.onComplete,
    this.particleCount = 34,
    this.colors,
  });

  /// Same seed, same burst. Usually the intention id — a promise celebrates
  /// itself the same way every time.
  final int seed;
  final VoidCallback? onComplete;
  final int particleCount;
  final List<Color>? colors;

  @override
  State<RewardBurst> createState() => _RewardBurstState();
}

class _RewardBurstState extends State<RewardBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.reward,
  );
  late final List<_Particle> _particles = _spawn(
    widget.seed,
    widget.particleCount,
  );

  @override
  void initState() {
    super.initState();
    _controller
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onComplete?.call();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette =
        widget.colors ??
        <Color>[
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.secondary,
          Theme.of(context).colorScheme.tertiary,
          const Color(0xFFF7E7A1),
        ];
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _BurstPainter(
              particles: _particles,
              progress: _controller.value,
              palette: palette,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

/// One petal: a launch direction, a speed, a spin, and a shape.
class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.size,
    required this.shape,
    required this.tint,
    required this.delay,
  });

  final double angle;
  final double speed;
  final double spin;
  final double size;

  /// 0 = leaf, 1 = petal disc, 2 = spark.
  final int shape;
  final int tint;

  /// Fraction of the animation to wait before launching, so the burst reads as
  /// a scatter rather than a ring.
  final double delay;
}

List<_Particle> _spawn(int seed, int count) {
  final random = math.Random(seed);
  return <_Particle>[
    for (var i = 0; i < count; i++)
      _Particle(
        // Biased upward: things thrown into the air, not a firework.
        angle: -math.pi / 2 + (random.nextDouble() - 0.5) * math.pi * 1.15,
        speed: 60 + random.nextDouble() * 120,
        spin: (random.nextDouble() - 0.5) * 10,
        size: 4 + random.nextDouble() * 6,
        shape: random.nextInt(3),
        tint: random.nextInt(4),
        delay: random.nextDouble() * 0.18,
      ),
  ];
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({
    required this.particles,
    required this.progress,
    required this.palette,
  });

  final List<_Particle> particles;
  final double progress;
  final List<Color> palette;

  /// Downward pull, in logical pixels per unit time squared.
  static const double _gravity = 260;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);
    final paint = Paint();

    for (final particle in particles) {
      final t = (progress - particle.delay) / (1 - particle.delay);
      if (t <= 0) continue;

      // Ballistic: constant launch velocity plus gravity. Cheaper than a
      // physics sim and reads exactly the same at this scale.
      final distance = particle.speed * t;
      final position = Offset(
        origin.dx + math.cos(particle.angle) * distance,
        origin.dy + math.sin(particle.angle) * distance + _gravity * t * t,
      );

      // Fade out over the back half only, so the burst is fully visible at its
      // peak rather than ghosting the whole way.
      final opacity = t < 0.5 ? 1.0 : 1 - (t - 0.5) * 2;
      if (opacity <= 0) continue;

      paint.color = palette[particle.tint % palette.length].withValues(
        alpha: opacity.clamp(0.0, 1.0),
      );

      canvas
        ..save()
        ..translate(position.dx, position.dy)
        ..rotate(particle.spin * t);

      switch (particle.shape) {
        case 0:
          // Leaf: a pointed oval.
          canvas.drawPath(
            Path()
              ..moveTo(0, -particle.size)
              ..quadraticBezierTo(particle.size * 0.8, 0, 0, particle.size)
              ..quadraticBezierTo(-particle.size * 0.8, 0, 0, -particle.size),
            paint,
          );
        case 1:
          canvas.drawCircle(Offset.zero, particle.size * 0.55, paint);
        default:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: particle.size * 0.5,
                height: particle.size * 1.4,
              ),
              const Radius.circular(2),
            ),
            paint,
          );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Shows a [RewardBurst] centred on the screen, above everything.
///
/// An overlay entry rather than a route: a celebration must never take the
/// user somewhere, block a tap, or land in the back stack. It removes itself.
///
/// No-ops under reduced motion (PRD §8.3) — the state change itself is still
/// announced by the snackbar and the haptic.
void showRewardBurst(BuildContext context, {required int seed}) {
  if (AppMotion.isReduced(context)) return;
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: RewardBurst(
        seed: seed,
        onComplete: () {
          if (entry.mounted) entry.remove();
        },
      ),
    ),
  );
  overlay.insert(entry);
}
