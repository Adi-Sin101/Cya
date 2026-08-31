import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_motion.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import 'cya_colors_extension.dart';

/// Builds the light and dark [ThemeData] for Cya! from the PRD design system
/// (§8.1). Material 3, Plus Jakarta Sans, rounded soft surfaces.
///
/// Component themes are sized to [AppTypography]'s scale rather than to
/// Material's defaults: a 15px label inside a 36dp-tall button looks like a
/// mistake, and every screen would otherwise have to override the same three
/// things.
abstract final class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(
    brightness: Brightness.light,
    scheme: const ColorScheme.light(
      primary: AppColors.sage,
      onPrimary: AppColors.onBrand,
      primaryContainer: AppColors.mint,
      onPrimaryContainer: AppColors.deepInk,
      secondary: AppColors.softSage,
      onSecondary: AppColors.onBrand,
      secondaryContainer: AppColors.lightMintWash,
      onSecondaryContainer: AppColors.deepInk,
      tertiary: AppColors.mint,
      onTertiary: AppColors.lightTextPrimary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightSurface2,
      onSurfaceVariant: AppColors.lightTextSecondary,
      outlineVariant: AppColors.lightOutline,
      error: AppColors.error,
      onError: AppColors.onBrand,
    ),
    background: AppColors.lightBackground,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    divider: AppColors.lightOutline,
    extension: CyaColors.light,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme.dark(
      primary: AppColors.softSage,
      onPrimary: AppColors.deepInk,
      primaryContainer: AppColors.sage,
      onPrimaryContainer: AppColors.mint,
      secondary: AppColors.mint,
      onSecondary: AppColors.deepInk,
      secondaryContainer: AppColors.darkMintWash,
      onSecondaryContainer: AppColors.mint,
      tertiary: AppColors.mint,
      onTertiary: AppColors.deepInk,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurface2,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outlineVariant: AppColors.darkOutline,
      error: AppColors.error,
      onError: AppColors.onBrand,
    ),
    background: AppColors.darkBackground,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    divider: AppColors.darkOutline,
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
      // Shared axis-ish transitions on every platform, so pushing a promise
      // detail feels the same wherever the app runs (PRD §8.3).
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        toolbarHeight: 64,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        // A hairline outline so an unselected chip still reads as a tappable
        // control; without it, filter and category chips look like plain text.
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surface,
        selectedColor: scheme.secondaryContainer,
        showCheckmark: false,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppTouch.buttonHeight),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppTouch.buttonHeight),
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: scheme.outlineVariant, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppTouch.minTarget),
          textStyle: textTheme.labelLarge,
          foregroundColor: scheme.primary,
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        minVerticalPadding: AppSpacing.md,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: extension.surface2,
        hintStyle: textTheme.bodyLarge?.copyWith(color: textSecondary),
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.dark
            ? AppColors.darkSurface2
            : AppColors.lightTextPrimary,
        contentTextStyle: textTheme.titleSmall?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        insetPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.navClearance - 40,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyLarge?.copyWith(color: textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: extension.surface2,
        linearMinHeight: 8,
      ),
      splashColor: scheme.primary.withValues(alpha: 0.08),
      highlightColor: scheme.primary.withValues(alpha: 0.04),
    );
  }

  /// Applies the app's text-scale clamp and hands the subtree the theme's
  /// [MediaQuery] (PRD §8.4). Used by both the splash and the app root.
  static Widget wrapMediaQuery(BuildContext context, Widget? child) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: AppTypography.clampScaler(media.textScaler),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }

  /// Re-exported so screens can reach motion tokens through the theme import
  /// they already have.
  static Duration motion(BuildContext context, Duration duration) =>
      AppMotion.of(context, duration);
}
