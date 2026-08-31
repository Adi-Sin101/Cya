import 'package:flutter/material.dart';

/// Raw design tokens from the PRD design system (§8.1).
///
/// These are the single source of truth for the palette's hex values. UI code
/// should prefer reading semantic colors from [ThemeData.colorScheme] or the
/// [CyaColors] theme extension rather than referencing these constants directly.
abstract final class AppColors {
  const AppColors._();

  // --- Brand triad (identical in light & dark) ---
  /// Primary — Sage.
  static const Color sage = Color(0xFF2E705B);

  /// Secondary — Soft Sage.
  static const Color softSage = Color(0xFF74B69D);

  /// Accent — Mint.
  static const Color mint = Color(0xFFA7D7C5);

  /// The darkest brand green. Used as *foreground* on mint/soft-sage fills,
  /// where white would fail contrast (PRD §8.4).
  static const Color deepInk = Color(0xFF10402F);

  // --- Semantic status (identical in light & dark) ---
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  /// Foreground drawn on top of the brand/status colors.
  static const Color onBrand = Color(0xFFFFFFFF);

  // --- Light surfaces & text ---
  static const Color lightBackground = Color(0xFFF7FAF8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF1F5F3);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF64748B);

  /// Hairline borders. Barely there on purpose — a card should be defined by
  /// its fill and its spacing, not by a drawn box (PRD §8.1 "soft surfaces").
  static const Color lightOutline = Color(0xFFE3EAE7);

  /// A pale mint fill for selected chips and tonal containers.
  static const Color lightMintWash = Color(0xFFDCEFE6);

  // --- Dark surfaces & text ---
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurface2 = Color(0xFF243137);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkOutline = Color(0xFF31424E);

  /// The dark theme's tonal container — the brand green, deepened enough to
  /// sit on the dark background without glowing.
  static const Color darkMintWash = Color(0xFF23453A);

  /// Brand gradient stops (§8.1): Sage → Soft Sage → Mint.
  static const List<Color> brandGradient = <Color>[sage, softSage, mint];
}
