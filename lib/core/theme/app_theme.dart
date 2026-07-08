import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'cya_colors_extension.dart';

/// Builds the light and dark [ThemeData] for Cya! from the PRD design system
/// (§8.1). Material 3, Plus Jakarta Sans, rounded soft surfaces.
abstract final class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(
    brightness: Brightness.light,
    scheme: const ColorScheme.light(
      primary: AppColors.sage,
      onPrimary: AppColors.onBrand,
      secondary: AppColors.softSage,
      onSecondary: AppColors.onBrand,
      tertiary: AppColors.mint,
      onTertiary: AppColors.lightTextPrimary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      error: AppColors.error,
      onError: AppColors.onBrand,
    ),
    background: AppColors.lightBackground,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    divider: AppColors.lightSurface2,
    extension: CyaColors.light,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme.dark(
      primary: AppColors.sage,
      onPrimary: AppColors.onBrand,
      secondary: AppColors.softSage,
      onSecondary: AppColors.onBrand,
      tertiary: AppColors.mint,
      onTertiary: AppColors.darkTextPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      error: AppColors.error,
      onError: AppColors.onBrand,
    ),
    background: AppColors.darkBackground,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    divider: AppColors.darkSurface2,
    extension: CyaColors.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color background,
    required Color textPrimary,
    required Color textSecondary,
    required Color divider,
    required CyaColors extension,
  }) {
    final TextTheme textTheme = AppTypography.textTheme(
      textPrimary,
      textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      dividerColor: divider,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[extension],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide.none,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
