import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design tokens that don't map cleanly onto Material's [ColorScheme] — the
/// success/warning status colors, the secondary surface tier, the brand
/// gradient, and the garden's sky. Attached to [ThemeData.extensions] and read
/// via `context.cyaColors` (see [CyaColorsX]).
@immutable
class CyaColors extends ThemeExtension<CyaColors> {
  const CyaColors({
    required this.success,
    required this.warning,
    required this.successInk,
    required this.warningInk,
    required this.errorInk,
    required this.surface2,
    required this.textSecondary,
    required this.gradient,
    required this.onGradient,
    required this.shadow,
    required this.skyTop,
    required this.skyBottom,
    required this.hillFar,
    required this.hillNear,
    required this.soil,
  });

  /// Status **fills** — the PRD's §8.1 values, used for a filled toggle, a
  /// tinted banner, a chip background.
  final Color success;
  final Color warning;

  /// Status **inks** — the same meanings, darkened for light backgrounds and
  /// lightened for dark ones so they pass contrast as *text*.
  ///
  /// The two are not interchangeable and the split is not pedantry: amber
  /// `#F59E0B` on white is 2.2:1, well under the 4.5:1 body-text floor
  /// (PRD §8.4), while the same amber is exactly right as a 12%-alpha banner
  /// wash. Reach for the ink whenever the colour is carrying letters.
  final Color successInk;
  final Color warningInk;
  final Color errorInk;

  final Color surface2;
  final Color textSecondary;
  final List<Color> gradient;

  /// Foreground for text sitting on [gradient] or on a mint/soft-sage fill.
  final Color onGradient;

  /// The colour cards cast. Tinted with the brand green rather than pure black,
  /// so elevation reads as warm depth instead of grime.
  final Color shadow;

  // --- Memory Garden scene (PRD §6.6) ---
  /// The garden's **daytime** sky for this theme, top and bottom of the
  /// gradient. Dusk and night are produced by lerping these toward the shared
  /// night palette — see `gardenPaletteOf`. Keeping only the day end here is
  /// what stops a light theme from painting a bright noon sky at 11pm.
  final Color skyTop;
  final Color skyBottom;

  /// The two parallax hill bands behind the beds.
  final Color hillFar;
  final Color hillNear;

  /// Earth the plants are rooted in.
  final Color soil;

  static const CyaColors light = CyaColors(
    success: AppColors.success,
    warning: AppColors.warning,
    successInk: Color(0xFF15803D),
    warningInk: Color(0xFFB45309),
    errorInk: Color(0xFFB91C1C),
    surface2: AppColors.lightSurface2,
    textSecondary: AppColors.lightTextSecondary,
    gradient: AppColors.brandGradient,
    onGradient: AppColors.onBrand,
    shadow: Color(0x1A2E705B),
    skyTop: Color(0xFFC5E6F2),
    skyBottom: Color(0xFFF0FAF4),
    hillFar: Color(0xFFB4DECC),
    hillNear: Color(0xFF8FCCB3),
    soil: Color(0xFF8A6446),
  );

  static const CyaColors dark = CyaColors(
    success: AppColors.success,
    warning: AppColors.warning,
    successInk: Color(0xFF4ADE80),
    warningInk: Color(0xFFFBBF24),
    errorInk: Color(0xFFFCA5A5),
    surface2: AppColors.darkSurface2,
    textSecondary: AppColors.darkTextSecondary,
    gradient: AppColors.brandGradient,
    onGradient: AppColors.onBrand,
    shadow: Color(0x66000000),
    // A dark theme's "day" is a dusky one: bright noon inside a dark UI is a
    // glare, not a garden.
    skyTop: Color(0xFF1D3E4E),
    skyBottom: Color(0xFF264A44),
    hillFar: Color(0xFF244F44),
    hillNear: Color(0xFF2F6555),
    soil: Color(0xFF4A3628),
  );

  @override
  CyaColors copyWith({
    Color? success,
    Color? warning,
    Color? successInk,
    Color? warningInk,
    Color? errorInk,
    Color? surface2,
    Color? textSecondary,
    List<Color>? gradient,
    Color? onGradient,
    Color? shadow,
    Color? skyTop,
    Color? skyBottom,
    Color? hillFar,
    Color? hillNear,
    Color? soil,
  }) {
    return CyaColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      successInk: successInk ?? this.successInk,
      warningInk: warningInk ?? this.warningInk,
      errorInk: errorInk ?? this.errorInk,
      surface2: surface2 ?? this.surface2,
      textSecondary: textSecondary ?? this.textSecondary,
      gradient: gradient ?? this.gradient,
      onGradient: onGradient ?? this.onGradient,
      shadow: shadow ?? this.shadow,
      skyTop: skyTop ?? this.skyTop,
      skyBottom: skyBottom ?? this.skyBottom,
      hillFar: hillFar ?? this.hillFar,
      hillNear: hillNear ?? this.hillNear,
      soil: soil ?? this.soil,
    );
  }

  @override
  CyaColors lerp(CyaColors? other, double t) {
    if (other == null) return this;
    return CyaColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      successInk: Color.lerp(successInk, other.successInk, t)!,
      warningInk: Color.lerp(warningInk, other.warningInk, t)!,
      errorInk: Color.lerp(errorInk, other.errorInk, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      gradient: <Color>[
        for (var i = 0; i < gradient.length; i++)
          Color.lerp(gradient[i], other.gradient[i], t)!,
      ],
      onGradient: Color.lerp(onGradient, other.onGradient, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      skyTop: Color.lerp(skyTop, other.skyTop, t)!,
      skyBottom: Color.lerp(skyBottom, other.skyBottom, t)!,
      hillFar: Color.lerp(hillFar, other.hillFar, t)!,
      hillNear: Color.lerp(hillNear, other.hillNear, t)!,
      soil: Color.lerp(soil, other.soil, t)!,
    );
  }
}

/// Convenience access to the [CyaColors] extension for the current theme.
///
/// Falls back to the palette matching the theme's brightness when the extension
/// is missing — a widget rendered outside the app's theme (a test harness, a
/// preview) should look plain, not crash.
extension CyaColorsX on BuildContext {
  CyaColors get cyaColors {
    final theme = Theme.of(this);
    return theme.extension<CyaColors>() ??
        (theme.brightness == Brightness.dark
            ? CyaColors.dark
            : CyaColors.light);
  }
}

/// The soft, brand-tinted elevation used by every raised surface.
///
/// One definition so cards, sheets and the FAB cast the *same* light — the
/// quickest way for a UI to look assembled rather than designed.
List<BoxShadow> cyaShadow(BuildContext context, {double elevation = 1}) {
  final shadow = context.cyaColors.shadow;
  return <BoxShadow>[
    BoxShadow(
      color: shadow,
      blurRadius: 18 * elevation,
      spreadRadius: -4 * elevation,
      offset: Offset(0, 6 * elevation),
    ),
  ];
}
