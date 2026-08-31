import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Edge-to-edge system bars (PRD §8.1 — the app should read as one surface).
///
/// Android draws an opaque status and navigation bar by default, which puts a
/// black or white band above and below the app. Against a deep navy dark theme
/// or an off-white light theme that band reads as a seam: the app looks pasted
/// into the screen rather than filling it.
///
/// Going edge-to-edge means the app's own background runs under both bars, so
/// there is nothing to mismatch. The only thing left to get right is the icon
/// colour — the clock and battery must be dark on our light background and
/// light on our dark one — which is what [applyFor] keeps in step with the
/// active theme.
abstract final class CyaSystemChrome {
  const CyaSystemChrome._();

  /// Call once at startup, before `runApp`.
  static void goEdgeToEdge() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      // Both bars stay visible and overlaid; the app just paints behind them.
      overlays: SystemUiOverlay.values,
    );
  }

  /// Matches the system bar icons to [brightness] — the brightness of the app's
  /// *background*, not of its icons.
  ///
  /// The two spellings are not redundant: `statusBarIconBrightness` is what
  /// Android reads, `statusBarBrightness` is what iOS reads, and they mean
  /// opposite things. Getting one wrong gives white icons on a white bar.
  static void applyFor(Brightness brightness) {
    final light = brightness == Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: light ? Brightness.dark : Brightness.light,
        statusBarBrightness: light ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: light
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarContrastEnforced: false,
        systemStatusBarContrastEnforced: false,
      ),
    );
  }
}

/// Keeps the system bar icons in step with the theme actually being rendered.
///
/// Placed inside `MaterialApp.builder`, so it sees the resolved brightness —
/// including `ThemeMode.system` and a mid-session theme switch, which a
/// one-shot call at startup would miss.
class SystemChromeSync extends StatelessWidget {
  const SystemChromeSync({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    CyaSystemChrome.applyFor(Theme.of(context).brightness);
    return child;
  }
}
