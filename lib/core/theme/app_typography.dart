import 'package:flutter/material.dart';

/// The Plus Jakarta Sans type scale (PRD §8.1).
///
/// The family is bundled in `pubspec.yaml`. Text colors come from the theme:
/// most styles use the primary text color; supporting styles use secondary.
///
/// The scale is deliberately large. A promise manager is read at a glance, one
/// hand, mid-stride — the sizes that survive that are not the sizes that look
/// balanced in a design tool at 2x zoom. Headlines carry negative tracking so
/// they stay tight rather than airy as they grow; body text keeps generous
/// line height so a two-line promise never looks cramped.
abstract final class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'PlusJakartaSans';

  /// Bounds on the OS font-size setting (PRD §8.4 — text must scale, but a
  /// 2x scaler on a 44px display style destroys every layout). Below 1.0 we
  /// allow only a little shrink: this scale exists to be readable.
  static const double minTextScale = 0.85;
  static const double maxTextScale = 1.35;

  /// Clamps [scaler] into the supported range.
  static TextScaler clampScaler(TextScaler scaler) =>
      scaler.clamp(minScaleFactor: minTextScale, maxScaleFactor: maxTextScale);

  static TextTheme textTheme(Color primary, Color secondary) {
    TextStyle style(
      double size,
      FontWeight weight, {
      double height = 1.3,
      double letterSpacing = 0,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color ?? primary,
      );
    }

    return TextTheme(
      // Display — hero numbers and the one thing a screen is about.
      displayLarge: style(
        44,
        FontWeight.w800,
        height: 1.02,
        letterSpacing: -1.4,
      ),
      displayMedium: style(
        36,
        FontWeight.w800,
        height: 1.06,
        letterSpacing: -1,
      ),
      displaySmall: style(
        30,
        FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.7,
      ),

      // Headline — screen titles and section heroes.
      headlineLarge: style(
        30,
        FontWeight.w700,
        height: 1.14,
        letterSpacing: -0.7,
      ),
      headlineMedium: style(
        26,
        FontWeight.w700,
        height: 1.18,
        letterSpacing: -0.5,
      ),
      headlineSmall: style(
        22,
        FontWeight.w700,
        height: 1.24,
        letterSpacing: -0.3,
      ),

      // Title — cards, list rows, section headers.
      titleLarge: style(20, FontWeight.w700, height: 1.28, letterSpacing: -0.2),
      titleMedium: style(18, FontWeight.w600, height: 1.32),
      titleSmall: style(16, FontWeight.w600, height: 1.34),

      // Body — everything the user actually reads.
      bodyLarge: style(18, FontWeight.w400, height: 1.5),
      bodyMedium: style(16, FontWeight.w400, height: 1.5, color: secondary),
      bodySmall: style(14, FontWeight.w400, height: 1.45, color: secondary),

      // Label — buttons, chips, metadata.
      labelLarge: style(15, FontWeight.w700, height: 1.2, letterSpacing: 0.1),
      labelMedium: style(
        13,
        FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.1,
        color: secondary,
      ),
      labelSmall: style(
        12,
        FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.2,
        color: secondary,
      ),
    );
  }
}
