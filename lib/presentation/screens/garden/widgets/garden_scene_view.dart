import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../domain/projections/garden_projection.dart';
import 'garden_scene_painter.dart';

/// Renders a set of plants as a living scene (PRD §6.6, §8.3).
///
/// Two animations, one controller each, both isolated behind a
/// [RepaintBoundary] so the garden breathing never repaints the text around it
/// (PRD §9.1):
///
/// - **grow-in** runs once when the scene appears, so plants rise out of the
///   soil rather than being there already;
/// - **wind** loops forever, and only when [animateWind] is set. History beds
///   are still on purpose: last month should not be waving at you, and 20
///   static beds all ticking would be 20 repaints a frame for no gain.
///
/// Under reduced motion neither controller ever runs and the scene renders
/// fully grown and still (PRD §8.3).
class GardenSceneView extends StatefulWidget {
  const GardenSceneView({
    super.key,
    required this.plants,
    required this.height,
    required this.now,
    this.showSky = true,
    this.animateWind = true,
    this.plantScale = 1,
  });

  final List<GardenPlant> plants;
  final double height;

  /// Drives the sky's time of day, so opening the garden at 11pm shows a night
  /// garden. The scene is a place, and places have a time.
  final DateTime now;

  final bool showSky;
  final bool animateWind;

  /// Scales every plant. See [GardenScenePainter.plantScale].
  final double plantScale;

  @override
  State<GardenSceneView> createState() => _GardenSceneViewState();
}

class _GardenSceneViewState extends State<GardenSceneView>
    with TickerProviderStateMixin {
  late final AnimationController _growth = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  );
  late final AnimationController _wind = AnimationController(
    vsync: this,
    duration: AppMotion.ambient,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.isReduced(context)) {
      _growth.value = 1;
      return;
    }
    _growth.forward();
    if (widget.animateWind) _wind.repeat();
  }

  @override
  void didUpdateWidget(GardenSceneView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateWind == oldWidget.animateWind) return;
    if (widget.animateWind && !AppMotion.isReduced(context)) {
      _wind.repeat();
    } else {
      _wind.stop();
    }
  }

  @override
  void dispose() {
    _growth.dispose();
    _wind.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nightness = nightnessAt(widget.now);
    final palette = gardenPaletteOf(context, nightness);
    final calm = AppMotion.isReduced(context);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_growth, _wind]),
        builder: (context, _) => CustomPaint(
          size: Size(double.infinity, widget.height),
          isComplex: widget.plants.length > 24,
          painter: GardenScenePainter(
            plants: widget.plants,
            palette: palette,
            growthScale: calm
                ? 1
                : AppMotion.grow.transform(_growth.value).clamp(0.0, 1.0),
            // A fixed phase when still, so a calm garden is not simply frozen
            // mid-gust with every plant leaning the same way.
            wind: calm || !widget.animateWind ? 0.25 : _wind.value,
            nightness: nightness,
            showSky: widget.showSky,
            plantScale: widget.plantScale,
          ),
        ),
      ),
    );
  }
}

// Night is night in either theme, so the far end of the day→night lerp is one
// shared set of colours rather than a per-theme one.
const Color _nightSkyTop = Color(0xFF0A1626);
const Color _nightSkyBottom = Color(0xFF15303A);
const Color _nightHillFar = Color(0xFF14302A);
const Color _nightHillNear = Color(0xFF1D453A);
const Color _nightSoil = Color(0xFF3A2A1F);

/// The garden's colours for the current theme **at a given time of day**.
///
/// The sky darkens with [nightness] rather than being fixed per theme. Without
/// this the light theme kept a pale noon sky while the painter drew a moon and
/// stars over it, and any text placed on that sky had to guess which one it
/// was contrasting against — which is exactly how white-on-white happens.
GardenPalette gardenPaletteOf(BuildContext context, double nightness) {
  final cya = context.cyaColors;
  final dark = Theme.of(context).brightness == Brightness.dark;
  final t = nightness.clamp(0.0, 1.0);
  return GardenPalette(
    skyTop: Color.lerp(cya.skyTop, _nightSkyTop, t)!,
    skyBottom: Color.lerp(cya.skyBottom, _nightSkyBottom, t)!,
    hillFar: Color.lerp(cya.hillFar, _nightHillFar, t)!,
    hillNear: Color.lerp(cya.hillNear, _nightHillNear, t)!,
    soil: Color.lerp(cya.soil, _nightSoil, t)!,
    stem: dark ? const Color(0xFF4E8F76) : AppColors.sage,
    // One colour per species. Deliberately close together — a garden is a
    // family of greens with two flowers in it, not a paint chart.
    foliage: <Color>[
      AppColors.softSage,
      const Color(0xFFE8A0B4), // bloom
      const Color(0xFF3F8C6E),
      const Color(0xFF56A085),
      const Color(0xFF7FC49F),
      const Color(0xFFE4B363), // tulip
      const Color(0xFF2E705B),
      const Color(0xFF8FCBB2),
    ],
  );
}

/// How deep into the night [at] is, `0..1`.
///
/// Full day 08:00–17:00, full night 21:00–05:00, with a smooth hour-long
/// ramp either side so dusk actually looks like dusk.
double nightnessAt(DateTime at) {
  final hour = at.hour + at.minute / 60;
  const dawnStart = 5.0;
  const dayStart = 8.0;
  const duskStart = 17.0;
  const nightStart = 21.0;

  if (hour >= dayStart && hour < duskStart) return 0;
  if (hour >= nightStart || hour < dawnStart) return 1;
  if (hour < dayStart) {
    // Dawn: night fading out.
    return 1 - _smooth((hour - dawnStart) / (dayStart - dawnStart));
  }
  // Dusk: night coming on.
  return _smooth((hour - duskStart) / (nightStart - duskStart));
}

/// Smoothstep — an ease that starts and ends flat, so sunrise has no corner.
double _smooth(double t) {
  final x = t.clamp(0.0, 1.0);
  return x * x * (3 - 2 * x);
}

/// A sensible height for a scene holding [plantCount] plants at [width].
///
/// Beds grow taller as they fill rather than cramming more plants into the
/// same strip, which is what keeps a 40-promise week legible.
double gardenSceneHeight(
  int plantCount,
  double width, {
  double base = 84,
  double plantScale = 1,
}) {
  final rows = GardenScenePainter.rowsFor(plantCount, width / plantScale);
  return base + (math.min(rows, 6) - 1) * 30 * plantScale;
}

/// Text colour that is guaranteed to read against the garden's sky at [now].
///
/// Derived from the *resolved* sky rather than from a theme flag or a
/// day/night boolean, so it cannot drift out of step with what the painter
/// actually drew — the failure mode this replaces was white copy sitting on a
/// pale mint sky at dusk.
Color gardenInkOn(BuildContext context, DateTime now) {
  final palette = gardenPaletteOf(context, nightnessAt(now));
  // Sampled a third of the way down, which is where the hero copy sits.
  final behind = Color.lerp(palette.skyTop, palette.skyBottom, 0.33)!;
  return behind.computeLuminance() > 0.45
      ? const Color(0xFF103024)
      : Colors.white;
}
