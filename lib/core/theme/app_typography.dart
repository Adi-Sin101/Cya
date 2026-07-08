import 'package:flutter/material.dart';

/// The Plus Jakarta Sans type scale (PRD §8.1).
///
/// The family is bundled in `pubspec.yaml`. Text colors come from the theme:
/// most styles use the primary text color; supporting styles use secondary.
abstract final class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'PlusJakartaSans';

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
      displayLarge: style(
        34,
        FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
      ),
      displayMedium: style(
        28,
        FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.4,
      ),
      headlineMedium: style(
        24,
        FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
      ),
      headlineSmall: style(20, FontWeight.w600, height: 1.3),
      titleLarge: style(18, FontWeight.w600, height: 1.3),
      titleMedium: style(16, FontWeight.w600, height: 1.35),
      titleSmall: style(14, FontWeight.w600, height: 1.35),
      bodyLarge: style(16, FontWeight.w400, height: 1.45),
      bodyMedium: style(14, FontWeight.w400, height: 1.45, color: secondary),
      bodySmall: style(12, FontWeight.w400, height: 1.4, color: secondary),
      labelLarge: style(14, FontWeight.w600, height: 1.2),
      labelMedium: style(12, FontWeight.w500, height: 1.2, color: secondary),
      labelSmall: style(11, FontWeight.w500, height: 1.2, color: secondary),
    );
  }
}
