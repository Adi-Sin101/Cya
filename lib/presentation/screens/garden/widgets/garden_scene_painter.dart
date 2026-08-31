import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../domain/projections/garden_projection.dart';

/// The palette one garden scene is painted from.
///
/// Passed in rather than read from the theme inside `paint`, so the painter
/// stays a pure function of its inputs and `shouldRepaint` can be honest.
@immutable
class GardenPalette {
  const GardenPalette({
    required this.skyTop,
    required this.skyBottom,
    required this.hillFar,
    required this.hillNear,
    required this.soil,
    required this.foliage,
    required this.stem,
  });

  final Color skyTop;
  final Color skyBottom;
  final Color hillFar;
  final Color hillNear;
  final Color soil;

  /// One colour per species, indexed by [GardenPlant.species].
  final List<Color> foliage;

  final Color stem;

  /// Value equality so [GardenScenePainter.shouldRepaint] can trust a palette
  /// comparison — the palette is rebuilt from the theme on every build, and
  /// identity would make the garden repaint for no reason.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GardenPalette &&
          other.skyTop == skyTop &&
          other.skyBottom == skyBottom &&
          other.hillFar == hillFar &&
          other.hillNear == hillNear &&
          other.soil == soil &&
          other.stem == stem &&
          _sameColors(other.foliage, foliage);

  @override
  int get hashCode => Object.hash(
    skyTop,
    skyBottom,
    hillFar,
    hillNear,
    soil,
    stem,
    Object.hashAll(foliage),
  );

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Paints the Memory Garden: sky, hills, soil, and one plant per kept promise
/// (PRD §6.6, §8.2 — "the emotional core of retention").
///
/// A single [CustomPainter] rather than a widget per plant. A mature garden
/// holds hundreds of them; painting the whole scene in one pass inside a
/// [RepaintBoundary] is how the app can breathe and still hold 60fps (§9.1).
///
/// Everything about a plant — species, height, lean, sway phase, where it
/// stands — is derived from its intention id. A kept promise always grows into
/// the same plant, in the same posture, in the same spot. The garden is a
/// memory, not a screensaver.
class GardenScenePainter extends CustomPainter {
  const GardenScenePainter({
    required this.plants,
    required this.palette,
    required this.growthScale,
    required this.wind,
    required this.nightness,
    this.showSky = true,
    this.plantScale = 1,
  });

  final List<GardenPlant> plants;
  final GardenPalette palette;

  /// Animates new growth in: `0..1`, applied on top of each plant's own growth.
  final double growthScale;

  /// Looping `0..1` phase driving the sway. Hold it at a constant for a still
  /// garden (reduced motion, or an old bed that should not be animating).
  final double wind;

  /// `0..1` — how deep into the night it is. Drives the sky, the sun/moon, and
  /// whether the ambient life is fireflies or pollen.
  final double nightness;

  /// Whether to paint sky, hills and celestial body. Off for the small
  /// history beds, which are strips of soil rather than landscapes.
  final bool showSky;

  /// Multiplies every plant's size. A plant drawn at its natural size inside a
  /// 260dp hero looks like a weed in a field; the same plant in a 76dp history
  /// strip looks right. One number, so the two surfaces share a painter.
  final double plantScale;

  /// Plants never crowd closer than this…
  static const double _minSpacing = 30;

  /// …and never spread further apart than this, so three plants read as a
  /// small cluster rather than three lonely stems.
  static const double _maxSpacing = 52;

  static const double _soilHeight = 16;
  static const double _rowHeight = 30;

  /// How many rows of plants a scene of [height] can hold.
  static int rowsFor(int plantCount, double width) {
    final perRow = math.max(1, (width / _minSpacing).floor());
    return math.max(1, (plantCount / perRow).ceil());
  }

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height - _soilHeight;

    if (showSky) {
      _paintSky(canvas, size, groundY);
      _paintHills(canvas, size, groundY);
    }
    _paintSoil(canvas, size, groundY);
    if (plants.isEmpty) return;

    // Plants wrap into rows, so a busy week grows upward instead of shrinking
    // every plant to fit. A quiet week spreads its few plants across the bed
    // rather than huddling them in one corner.
    final perRow = math.max(
      1,
      (size.width / (_minSpacing * plantScale)).floor(),
    );
    final inFirstRow = math.min(plants.length, perRow);
    final spacing = math.min(
      _maxSpacing * plantScale,
      size.width / (inFirstRow + 0.6),
    );
    final rowWidth = spacing * inFirstRow;
    final left = (size.width - rowWidth) / 2;

    // Back rows first: later rows sit lower on the canvas and must overlap the
    // ones behind them, or the bed looks flat.
    final rowCount = (plants.length / perRow).ceil();
    for (var row = rowCount - 1; row >= 0; row--) {
      final start = row * perRow;
      final end = math.min(start + perRow, plants.length);
      final y = groundY - row * _rowHeight * plantScale;
      // Rows further back are smaller and paler — cheap aerial perspective.
      final depth = rowCount == 1 ? 0.0 : row / rowCount;
      for (var i = start; i < end; i++) {
        final x = left + spacing * ((i - start) + 0.5);
        _paintPlant(canvas, Offset(x, y), plants[i], depth);
      }
    }

    if (showSky) _paintAmbient(canvas, size, groundY);
  }

  // --- Backdrop -------------------------------------------------------------

  void _paintSky(Canvas canvas, Size size, double groundY) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[palette.skyTop, palette.skyBottom],
        ).createShader(rect),
    );

    final celestialX = size.width * (0.18 + 0.5 * nightness);
    final celestialY = size.height * 0.24;
    final centre = Offset(celestialX, celestialY);

    if (nightness < 0.5) {
      // Sun: a disc with a wide, soft corona.
      final strength = 1 - nightness * 2;
      canvas
        ..drawCircle(
          centre,
          30,
          Paint()
            ..color = const Color(0xFFFFE9A8).withValues(alpha: 0.35 * strength)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
        )
        ..drawCircle(
          centre,
          13,
          Paint()
            ..color = const Color(
              0xFFFFF2C4,
            ).withValues(alpha: 0.95 * strength),
        );
    } else {
      final strength = (nightness - 0.5) * 2;
      // Stars, scattered deterministically so they don't twinkle-jump between
      // frames.
      final random = math.Random(7);
      final star = Paint()..color = Colors.white.withValues(alpha: strength);
      for (var i = 0; i < 26; i++) {
        final x = random.nextDouble() * size.width;
        // Capped above the far hill's crest — a star behind a hill is a bug
        // the eye notices immediately.
        final y = random.nextDouble() * size.height * 0.55;
        canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.1 + 0.5, star);
      }
      // Moon: a disc with a bite taken out by a background-coloured disc.
      canvas
        ..drawCircle(
          centre,
          26,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.16 * strength)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
        )
        ..saveLayer(null, Paint())
        ..drawCircle(
          centre,
          12,
          Paint()..color = const Color(0xFFF3F6FF).withValues(alpha: strength),
        )
        ..drawCircle(
          centre.translate(6, -4),
          11,
          Paint()..blendMode = BlendMode.clear,
        )
        ..restore();
    }
  }

  void _paintHills(Canvas canvas, Size size, double groundY) {
    void band(double crest, double amplitude, Color color) {
      final baseline = groundY - crest;
      final path = Path()..moveTo(0, size.height);
      path.lineTo(0, baseline);
      // Two arcs across the width read as rolling ground; one reads as a bump.
      path
        ..quadraticBezierTo(
          size.width * 0.25,
          baseline - amplitude,
          size.width * 0.5,
          baseline,
        )
        ..quadraticBezierTo(
          size.width * 0.75,
          baseline + amplitude * 0.6,
          size.width,
          baseline - amplitude * 0.3,
        )
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    band(size.height * 0.30, size.height * 0.10, palette.hillFar);
    band(size.height * 0.14, size.height * 0.06, palette.hillNear);
  }

  void _paintSoil(Canvas canvas, Size size, double groundY) {
    final rect = Rect.fromLTWH(0, groundY, size.width, size.height - groundY);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        bottomLeft: const Radius.circular(18),
        bottomRight: const Radius.circular(18),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            palette.soil,
            Color.lerp(palette.soil, Colors.black, 0.25)!,
          ],
        ).createShader(rect),
    );

    // A lighter lip along the top, so plants look rooted in the soil rather
    // than standing on a bar.
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, 3),
      Paint()..color = Color.lerp(palette.soil, Colors.white, 0.22)!,
    );

    // Grit. Deterministic, so it does not crawl between repaints.
    final random = math.Random(31);
    final speck = Paint()
      ..color = Color.lerp(
        palette.soil,
        Colors.black,
        0.35,
      )!.withValues(alpha: 0.5);
    for (var i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          groundY + 4 + random.nextDouble() * (size.height - groundY - 6),
        ),
        random.nextDouble() * 1.3 + 0.4,
        speck,
      );
    }
  }

  /// Fireflies at night, drifting pollen by day. Twelve of them — enough for
  /// the scene to feel inhabited, few enough to be free.
  void _paintAmbient(Canvas canvas, Size size, double groundY) {
    final random = math.Random(13);
    final night = nightness > 0.5;
    for (var i = 0; i < 12; i++) {
      final phase = random.nextDouble();
      final baseX = random.nextDouble() * size.width;
      final baseY = groundY * (0.25 + random.nextDouble() * 0.6);
      final t = (wind + phase) % 1.0;

      // A lazy figure-of-eight, so nothing tracks in a straight line.
      final x = baseX + math.sin(t * 2 * math.pi) * 14;
      final y = baseY + math.sin(t * 4 * math.pi) * 7;

      if (night) {
        final glow = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * 6 * math.pi));
        canvas
          ..drawCircle(
            Offset(x, y),
            4.5,
            Paint()
              ..color = const Color(0xFFFFF3A8).withValues(alpha: 0.30 * glow)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          )
          ..drawCircle(
            Offset(x, y),
            1.5,
            Paint()
              ..color = const Color(0xFFFFF9D6).withValues(alpha: 0.9 * glow),
          );
      } else {
        canvas.drawCircle(
          Offset(x, y),
          1.6,
          Paint()..color = Colors.white.withValues(alpha: 0.55),
        );
      }
    }
  }

  // --- Plants ---------------------------------------------------------------

  void _paintPlant(
    Canvas canvas,
    Offset base,
    GardenPlant plant,
    double depth,
  ) {
    final growth = (plant.growth * growthScale).clamp(0.0, 1.0);
    if (growth <= 0.02) return;

    // Deterministic variation: same promise, same posture, every time.
    final variation = _hash01(plant.intentionId);
    final phase = _hash01(plant.intentionId * 31 + 7);

    // Aerial perspective: rows further back are smaller and washed toward the
    // sky, which is what turns a grid of plants into a depth of field.
    final scale = (1 - depth * 0.22) * plantScale;
    final color = Color.lerp(
      palette.foliage[plant.species % palette.foliage.length],
      palette.skyBottom,
      depth * 0.35,
    )!;

    final height = (20 + 30 * growth) * (0.85 + variation * 0.3) * scale;
    final sway =
        math.sin((wind + phase) * 2 * math.pi) * (2.5 + variation * 2.5);
    final lean = (variation - 0.5) * 8 * growth + sway * growth;
    final tip = base.translate(lean, -height);

    _paintGroundShadow(canvas, base, height, growth, scale);

    // A stem with a slight bend reads as grown; a straight line reads as a
    // stick. Species 4 and 7 grow from the ground with no stem of their own.
    if (plant.species != 4 && plant.species != 7) {
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(
            base.dx + lean * 0.2,
            base.dy - height * 0.55,
            tip.dx,
            tip.dy,
          ),
        Paint()
          ..color = palette.stem
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 * scale
          ..strokeCap = StrokeCap.round,
      );
    }

    switch (plant.species % GardenProjection.speciesCount) {
      case 0:
        _sprout(canvas, base, tip, height, lean, growth, color, scale);
      case 1:
        _bloom(canvas, base, tip, height, lean, growth, color, scale);
      case 2:
        _bush(canvas, tip, growth, color, scale);
      case 3:
        _sapling(canvas, tip, growth, color, scale, variation);
      case 4:
        _grass(canvas, base, height, growth, color, scale, sway);
      case 5:
        _tulip(canvas, tip, growth, color, scale);
      case 6:
        _fern(canvas, base, height, lean, growth, color, scale);
      default:
        _succulent(canvas, base, growth, color, scale);
    }
  }

  /// A soft ellipse on the soil. The single cheapest thing that stops plants
  /// looking like stickers.
  void _paintGroundShadow(
    Canvas canvas,
    Offset base,
    double height,
    double growth,
    double scale,
  ) {
    canvas.drawOval(
      Rect.fromCenter(
        center: base.translate(0, 2),
        width: (14 + height * 0.22) * scale,
        height: 5 * scale,
      ),
      Paint()
        ..color = Color.lerp(
          palette.soil,
          Colors.black,
          0.5,
        )!.withValues(alpha: 0.3 * growth),
    );
  }

  /// Paired leaves climbing the stem.
  void _sprout(
    Canvas canvas,
    Offset base,
    Offset tip,
    double height,
    double lean,
    double growth,
    Color color,
    double scale,
  ) {
    _leaf(
      canvas,
      base.translate(lean * .3, -height * .42),
      -1,
      growth,
      color,
      scale,
    );
    _leaf(
      canvas,
      base.translate(lean * .6, -height * .70),
      1,
      growth,
      color,
      scale,
    );
    _leaf(canvas, tip, -1, growth * 0.7, color, scale);
  }

  /// A five-petal flower with a paler centre.
  void _bloom(
    Canvas canvas,
    Offset base,
    Offset tip,
    double height,
    double lean,
    double growth,
    Color color,
    double scale,
  ) {
    final radius = (6.5 * growth + 3) * scale;
    final petal = Paint()..color = color;
    final highlight = Paint()..color = Color.lerp(color, Colors.white, 0.3)!;
    for (var i = 0; i < 5; i++) {
      final angle = i * (2 * math.pi / 5) - math.pi / 2;
      final at = tip.translate(
        math.cos(angle) * radius * 0.78,
        math.sin(angle) * radius * 0.78,
      );
      canvas
        ..drawCircle(at, radius * 0.64, petal)
        // Light from the upper left, consistently, on every petal.
        ..drawCircle(
          at.translate(-radius * .16, -radius * .16),
          radius * .34,
          highlight,
        );
    }
    canvas.drawCircle(
      tip,
      radius * 0.46,
      Paint()..color = const Color(0xFFF7E7A1),
    );
    _leaf(
      canvas,
      base.translate(lean * .3, -height * .45),
      -1,
      growth,
      color,
      scale,
    );
  }

  /// Overlapping foliage with a few berries.
  void _bush(
    Canvas canvas,
    Offset tip,
    double growth,
    Color color,
    double scale,
  ) {
    const clumps = <Offset>[
      Offset(-7, 2),
      Offset(7, 2),
      Offset(-2, -6),
      Offset(5, -8),
      Offset(0, 0),
    ];
    final fill = Paint()..color = color;
    final lit = Paint()..color = Color.lerp(color, Colors.white, 0.22)!;
    for (final offset in clumps) {
      final at = tip.translate(
        offset.dx * growth * scale,
        offset.dy * growth * scale,
      );
      canvas
        ..drawCircle(at, (6.5 * growth + 2) * scale, fill)
        ..drawCircle(at.translate(-1.5, -1.5), (3.2 * growth + 1) * scale, lit);
    }
    if (growth > 0.7) {
      final berry = Paint()..color = const Color(0xFFE05C6E);
      for (final offset in const <Offset>[Offset(-4, 0), Offset(6, -3)]) {
        canvas.drawCircle(
          tip.translate(offset.dx * scale, offset.dy * scale),
          2 * scale,
          berry,
        );
      }
    }
  }

  /// A rounded canopy on a trunk, occasionally fruiting.
  void _sapling(
    Canvas canvas,
    Offset tip,
    double growth,
    Color color,
    double scale,
    double variation,
  ) {
    final canopy = Rect.fromCenter(
      center: tip.translate(0, -4 * growth * scale),
      width: (26 * growth + 8) * scale,
      height: (21 * growth + 7) * scale,
    );
    canvas
      ..drawOval(canopy, Paint()..color = color)
      ..drawOval(
        canopy.translate(-2.5, -2.5).deflate(canopy.width * 0.22),
        Paint()..color = Color.lerp(color, Colors.white, 0.2)!,
      );
    if (variation > 0.5 && growth > 0.75) {
      final fruit = Paint()..color = const Color(0xFFF0A04B);
      canvas
        ..drawCircle(canopy.centerLeft.translate(6, 4), 2.4 * scale, fruit)
        ..drawCircle(canopy.centerRight.translate(-7, -2), 2.4 * scale, fruit);
    }
  }

  /// Blades fanning from the base — the only plant that sways from its root.
  void _grass(
    Canvas canvas,
    Offset base,
    double height,
    double growth,
    Color color,
    double scale,
    double sway,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3 * scale
      ..strokeCap = StrokeCap.round;
    for (final angle in const <double>[-0.6, -0.25, 0.05, 0.35, 0.65]) {
      final tilt = angle + sway * 0.035;
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(
            base.dx + tilt * height * 0.5,
            base.dy - height * 0.62,
            base.dx + tilt * height * 0.95,
            base.dy - height * (0.78 - tilt.abs() * 0.35),
          ),
        paint,
      );
    }
  }

  /// A closed cup on a straight stem.
  void _tulip(
    Canvas canvas,
    Offset tip,
    double growth,
    Color color,
    double scale,
  ) {
    final w = (11 * growth + 4) * scale;
    final h = (14 * growth + 5) * scale;
    final cup = Path()
      ..moveTo(tip.dx - w / 2, tip.dy)
      ..quadraticBezierTo(tip.dx - w / 2, tip.dy - h, tip.dx, tip.dy - h * 0.86)
      ..quadraticBezierTo(tip.dx + w / 2, tip.dy - h, tip.dx + w / 2, tip.dy)
      ..quadraticBezierTo(tip.dx, tip.dy + h * 0.28, tip.dx - w / 2, tip.dy)
      ..close();
    canvas
      ..drawPath(cup, Paint()..color = color)
      // A single lit petal edge, rather than a full second cup — enough to
      // read as volume, one path cheaper.
      ..drawPath(
        Path()
          ..moveTo(tip.dx - w * 0.18, tip.dy - h * 0.05)
          ..quadraticBezierTo(
            tip.dx - w * 0.34,
            tip.dy - h * 0.8,
            tip.dx,
            tip.dy - h * 0.8,
          )
          ..quadraticBezierTo(
            tip.dx - w * 0.1,
            tip.dy - h * 0.4,
            tip.dx - w * 0.18,
            tip.dy - h * 0.05,
          ),
        Paint()..color = Color.lerp(color, Colors.white, 0.28)!,
      );
  }

  /// An arching frond with pinnae down both sides.
  void _fern(
    Canvas canvas,
    Offset base,
    double height,
    double lean,
    double growth,
    Color color,
    double scale,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * scale
      ..strokeCap = StrokeCap.round;
    for (final direction in const <double>[-1, 1]) {
      final spine = Path()..moveTo(base.dx, base.dy);
      final tipX = base.dx + lean + direction * height * 0.42;
      final tipY = base.dy - height * 0.92;
      spine.quadraticBezierTo(
        base.dx + direction * height * 0.1,
        base.dy - height * 0.6,
        tipX,
        tipY,
      );
      canvas.drawPath(spine, paint);

      // Pinnae get shorter toward the tip, which is what makes a frond a frond.
      for (var i = 1; i <= 5; i++) {
        final t = i / 6;
        final at = Offset(
          base.dx + (tipX - base.dx) * t + direction * height * 0.05,
          base.dy - height * 0.92 * t,
        );
        final length = 7 * (1 - t * 0.7) * growth * scale;
        canvas.drawLine(
          at,
          at.translate(direction * length, -length * 0.5),
          paint,
        );
      }
    }
  }

  /// A rosette of pointed pads, seen from slightly above.
  void _succulent(
    Canvas canvas,
    Offset base,
    double growth,
    Color color,
    double scale,
  ) {
    final radius = (13 * growth + 4) * scale;
    for (var ring = 2; ring >= 0; ring--) {
      final ringRadius = radius * (0.45 + ring * 0.28);
      final tint = Color.lerp(color, Colors.white, ring * 0.14)!;
      final pads = 6 + ring * 2;
      for (var i = 0; i < pads; i++) {
        final angle = i * (2 * math.pi / pads) + ring * 0.4;
        final outer = Offset(
          base.dx + math.cos(angle) * ringRadius,
          base.dy - 3 * scale + math.sin(angle) * ringRadius * 0.5,
        );
        canvas.drawPath(
          Path()
            ..moveTo(base.dx, base.dy - 3 * scale)
            ..quadraticBezierTo(
              base.dx + math.cos(angle - 0.4) * ringRadius * 0.7,
              base.dy - 3 * scale + math.sin(angle - 0.4) * ringRadius * 0.35,
              outer.dx,
              outer.dy,
            )
            ..quadraticBezierTo(
              base.dx + math.cos(angle + 0.4) * ringRadius * 0.7,
              base.dy - 3 * scale + math.sin(angle + 0.4) * ringRadius * 0.35,
              base.dx,
              base.dy - 3 * scale,
            ),
          Paint()..color = tint,
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
    double scale,
  ) {
    final length = 13 * growth * scale;
    canvas.drawPath(
      Path()
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
        ),
      Paint()..color = color,
    );
  }

  /// A stable `0..1` from an id — Knuth's multiplicative hash, so neighbouring
  /// ids do not produce neighbouring plants.
  static double _hash01(int value) => (value * 2654435761) % 1000 / 1000;

  @override
  bool shouldRepaint(GardenScenePainter oldDelegate) =>
      oldDelegate.growthScale != growthScale ||
      oldDelegate.wind != wind ||
      oldDelegate.nightness != nightness ||
      oldDelegate.plantScale != plantScale ||
      oldDelegate.plants.length != plants.length ||
      oldDelegate.palette != palette;
}
