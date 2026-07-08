import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design tokens that don't map cleanly onto Material's [ColorScheme] — the
/// success/warning status colors, the secondary surface tier, and the brand
/// gradient. Attached to [ThemeData.extensions] and read via
/// `context.cyaColors` (see [CyaColorsX]).
@immutable
class CyaColors extends ThemeExtension<CyaColors> {
  const CyaColors({
    required this.success,
    required this.warning,
    required this.surface2,
    required this.textSecondary,
    required this.gradient,
  });

  final Color success;
  final Color warning;
  final Color surface2;
  final Color textSecondary;
  final List<Color> gradient;

  static const CyaColors light = CyaColors(
    success: AppColors.success,
    warning: AppColors.warning,
    surface2: AppColors.lightSurface2,
    textSecondary: AppColors.lightTextSecondary,
    gradient: AppColors.brandGradient,
  );

  static const CyaColors dark = CyaColors(
    success: AppColors.success,
    warning: AppColors.warning,
    surface2: AppColors.darkSurface2,
    textSecondary: AppColors.darkTextSecondary,
    gradient: AppColors.brandGradient,
  );

  @override
  CyaColors copyWith({
    Color? success,
    Color? warning,
    Color? surface2,
    Color? textSecondary,
    List<Color>? gradient,
  }) {
    return CyaColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      surface2: surface2 ?? this.surface2,
      textSecondary: textSecondary ?? this.textSecondary,
      gradient: gradient ?? this.gradient,
    );
  }

  @override
  CyaColors lerp(CyaColors? other, double t) {
    if (other == null) return this;
    return CyaColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      gradient: <Color>[
        for (var i = 0; i < gradient.length; i++)
          Color.lerp(gradient[i], other.gradient[i], t)!,
      ],
    );
  }
}

/// Convenience access to the [CyaColors] extension for the current theme.
extension CyaColorsX on BuildContext {
  CyaColors get cyaColors => Theme.of(this).extension<CyaColors>()!;
}
