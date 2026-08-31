import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../domain/projections/garden_projection.dart';

/// Paints one week's bed of plants.
///
/// A `CustomPainter` rather than a widget per plant: a mature garden holds
/// hundreds of them, and the scene is static between writes. Painting it once
/// inside a `RepaintBoundary` is how the app stays at 60fps while still looking
/// alive (PRD §9.1 — beauty and performance, co-equal).
///
/// Every plant's shape, height and lean are derived from its intention id, so a
/// kept promise always grows into the same plant in the same posture. The
/// garden is a memory, not a screensaver.
class GardenBedPainter extends CustomPainter {
  const GardenBedPainter({
    required this.plants,
    required this.soil,
    required this.palette,
    required this.growthScale,
  });

  final List<GardenPlant> plants;
  final Color soil;

  /// One colour per species, indexed by [GardenPlant.species].
  final List<Color> palette;

  /// Animates new growth in: `0..1`, applied on top of each plant's own growth.
  final double growthScale;

  /// Plants never crowd closer than this…
  static const double _minSpacing = 34;

  /// …and never spread further apart than this, so three plants read as a small
  /// cluster rather than three lonely stems.
  static const double _maxSpacing = 56;

  static const double _soilHeight = 12;
  static const double _rowHeight = 26;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height - _soilHeight;
    _paintSoil(canvas, size, groundY);
    if (plants.isEmpty) return;

    // Plants wrap into rows, so a busy week grows upward instead of shrinking
    // every plant to fit. A quiet week spreads its few plants across the bed
    // rather than huddling them in one corner.
    final perRow = math.max(1, (size.width / _minSpacing).floor());
    final inFirstRow = math.min(plants.length, perRow);
    final spacing = math.min(_maxSpacing, size.width / (inFirstRow + 0.6));
    final rowWidth = spacing * inFirstRow;
    final left = (size.width - rowWidth) / 2;

    for (var i = 0; i < plants.length; i++) {
      final column = i % perRow;
      final row = i ~/ perRow;
      final x = left + spacing * (column + 0.5);
      _paintPlant(canvas, Offset(x, groundY - row * _rowHeight), plants[i]);
    }
  }

  void _paintSoil(Canvas canvas, Size size, double groundY) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, groundY, size.width, _soilHeight),
        const Radius.circular(6),
      ),
      Paint()..color = soil,
    );
    // A lighter lip along the top, so plants look rooted in the soil rather
    // than standing on a bar.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, groundY, size.width, 4),
        const Radius.circular(2),
      ),
      Paint()..color = soil.withValues(alpha: 0.5),
    );
  }

  void _paintPlant(Canvas canvas, Offset base, GardenPlant plant) {
    final growth = (plant.growth * growthScale).clamp(0.0, 1.0);
    if (growth <= 0.02) return;

    final color = palette[plant.species % palette.length];
    // Deterministic variation: same promise, same posture, every time.
    final variation = (plant.intentionId * 2654435761) % 1000 / 1000;
    final height = (18 + 26 * growth) * (0.85 + variation * 0.3);
    final lean = (variation - 0.5) * 8 * growth;
    final tip = base.translate(lean, -height);

    // A stem with a slight bend reads as grown; a straight line reads as a
    // stick.
    final stem = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx + lean * 0.2,
        base.dy - height * 0.55,
        tip.dx,
        tip.dy,
      );
    canvas.drawPath(
      stem,
      Paint()
        ..color = const Color(0xFF2E705B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    switch (plant.species % 5) {
      case 0:
        // Sprout: paired leaves climbing the stem.
        _leaf(
          canvas,
          base.translate(lean * 0.3, -height * 0.45),
          -1,
          growth,
          color,
        );
        _leaf(
          canvas,
          base.translate(lean * 0.6, -height * 0.72),
          1,
          growth,
          color,
        );
        _leaf(canvas, tip, -1, growth * 0.7, color);
      case 1:
        // Bloom: a flower head with a paler centre.
        final radius = 5.5 * growth + 2.5;
        for (var petal = 0; petal < 5; petal++) {
          final angle = petal * (2 * math.pi / 5) - math.pi / 2;
          canvas.drawCircle(
            tip.translate(
              math.cos(angle) * radius * 0.75,
              math.sin(angle) * radius * 0.75,
            ),
            radius * 0.62,
            Paint()..color = color,
          );
        }
        canvas.drawCircle(
          tip,
          radius * 0.45,
          Paint()..color = const Color(0xFFF7E7A1),
        );
        _leaf(
          canvas,
          base.translate(lean * 0.3, -height * 0.45),
          -1,
          growth,
          color,
        );
      case 2:
        // Bush: overlapping foliage.
        for (final offset in const <Offset>[
          Offset(-6, 1),
          Offset(6, 1),
          Offset(-2, -6),
          Offset(4, -7),
        ]) {
          canvas.drawCircle(
            tip.translate(offset.dx * growth, offset.dy * growth),
            5.5 * growth + 1.5,
            Paint()..color = color.withValues(alpha: 0.92),
          );
        }
      case 3:
        // Sapling: a rounded canopy on a trunk.
        final canopy = Rect.fromCenter(
          center: tip.translate(0, -3 * growth),
          width: 22 * growth + 6,
          height: 18 * growth + 6,
        );
        canvas
          ..drawOval(canopy, Paint()..color = color)
          ..drawOval(
            canopy.translate(-2, -2).deflate(4),
            Paint()..color = Color.lerp(color, Colors.white, 0.18)!,
          );
      default:
        // Grass tuft: blades fanning from the base.
        for (final angle in const <double>[-0.55, -0.2, 0.15, 0.5]) {
          final blade = Path()
            ..moveTo(base.dx, base.dy)
            ..quadraticBezierTo(
              base.dx + angle * height * 0.5,
              base.dy - height * 0.6,
              base.dx + angle * height * 0.9,
              base.dy - height * (0.75 - angle.abs() * 0.35),
            );
          canvas.drawPath(
            blade,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.1
              ..strokeCap = StrokeCap.round,
          );
        }
    }
  }

  void _leaf(
    Canvas canvas,
    Offset at,
    double direction,
    double growth,
    Color color,
  ) {
    final length = 12 * growth;
    final path = Path()
      ..moveTo(at.dx, at.dy)
      ..quadraticBezierTo(
        at.dx + direction * length * 0.7,
        at.dy - length * 0.7,
        at.dx + direction * length,
        at.dy - length * 0.15,
      )
      ..quadraticBezierTo(
        at.dx + direction * length * 0.6,
        at.dy + length * 0.35,
        at.dx,
        at.dy,
      );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(GardenBedPainter oldDelegate) =>
      oldDelegate.growthScale != growthScale ||
      oldDelegate.plants.length != plants.length ||
      oldDelegate.soil != soil;
}
