import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/cya_colors_extension.dart';
import '../providers/app_icon_provider.dart';

/// The square badge at the head of a promise row: where it came from.
///
/// Three tiers, best first:
///
/// 1. **The source app's real launcher icon**, read from the package manager
///    for the package the capture path recorded. Recognising WhatsApp's actual
///    icon in a list is instant in a way that a generic speech bubble never is.
/// 2. **A brand glyph**, for a handful of apps we recognise by name — which is
///    all we have when a promise predates `source_package`, or when the sharer
///    could not be attributed to a package.
/// 3. **Cya!'s own mascot**, for an in-app capture or an unknown source. Not a
///    grey bookmark: the bookmark made every unattributed promise look like a
///    filing-system artefact, where the mascot makes it look like something
///    Cya! is personally holding for you (PRD §8.1).
///
/// The icon arrives asynchronously over a platform channel, so it cross-fades
/// in over the fallback rather than popping a hole in the row while it loads.
class SourceAvatar extends ConsumerWidget {
  const SourceAvatar({
    super.key,
    required this.sourceApp,
    this.sourcePackage,
    this.size = 46,
    this.dimmed = false,
  });

  final String sourceApp;

  /// The Android package the promise was shared from, when one was recorded.
  final String? sourcePackage;

  final double size;

  /// Fades the badge back once its promise is done.
  final bool dimmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final package = sourcePackage;
    final icon = package == null || package.isEmpty
        ? null
        : ref.watch(appIconProvider(package)).valueOrNull;

    return Opacity(
      opacity: dimmed ? 0.45 : 1,
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.gentle),
            child: icon == null
                ? _Fallback(
                    key: const ValueKey<String>('fallback'),
                    sourceApp: sourceApp,
                    size: size,
                  )
                : ColoredBox(
                    key: ValueKey<String>('icon-$package'),
                    // A neutral plate behind every real icon. Launcher icons
                    // are wildly inconsistent — an adaptive one fills its
                    // square, a legacy one floats in a sea of transparency —
                    // and without a plate a row of them reads as icons at
                    // random sizes rather than a column of badges.
                    color: context.cyaColors.surface2,
                    child: Padding(
                      padding: EdgeInsets.all(size * 0.09),
                      child: Image.memory(
                        icon,
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                        // Rasterised at 144px for a ~46dp badge, so the
                        // downscale wants a real filter rather than nearest.
                        filterQuality: FilterQuality.medium,
                        gaplessPlayback: true,
                        errorBuilder: (context, _, _) =>
                            _Fallback(sourceApp: sourceApp, size: size),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({super.key, required this.sourceApp, required this.size});

  final String sourceApp;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visual = knownAppVisual(sourceApp);
    if (visual == null) {
      return Image.asset(
        'lib/assets/images/cya-logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, _, _) => ColoredBox(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
          child: Icon(
            Icons.bookmark_rounded,
            size: size * 0.48,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    return ColoredBox(
      color: visual.color.withValues(alpha: 0.14),
      child: Icon(visual.icon, size: size * 0.48, color: visual.color),
    );
  }
}

/// Iconography for source apps Cya! recognises **by label**, used when no
/// package was recorded. `null` means "not one we know" — the caller shows the
/// mascot.
({IconData icon, Color color})? knownAppVisual(String app) {
  return switch (app.toLowerCase()) {
    'messenger' => (icon: Icons.chat_bubble_rounded, color: Color(0xFF0084FF)),
    'whatsapp' => (icon: Icons.chat_rounded, color: Color(0xFF25D366)),
    'chrome' => (icon: Icons.public_rounded, color: Color(0xFF4285F4)),
    'github' => (icon: Icons.code_rounded, color: Color(0xFF6E5494)),
    'amazon' => (icon: Icons.shopping_bag_rounded, color: Color(0xFFFF9900)),
    'gmail' => (icon: Icons.mail_rounded, color: Color(0xFFEA4335)),
    'youtube' => (
      icon: Icons.play_circle_fill_rounded,
      color: Color(0xFFFF0000),
    ),
    'slack' => (icon: Icons.tag_rounded, color: Color(0xFF611F69)),
    'linkedin' => (icon: Icons.work_rounded, color: Color(0xFF0A66C2)),
    'x' || 'twitter' => (
      icon: Icons.alternate_email_rounded,
      color: Color(0xFF1D9BF0),
    ),
    'reddit' => (icon: Icons.forum_rounded, color: Color(0xFFFF4500)),
    'instagram' => (icon: Icons.camera_alt_rounded, color: Color(0xFFE1306C)),
    'telegram' => (icon: Icons.send_rounded, color: Color(0xFF29A9EB)),
    'spotify' => (icon: Icons.music_note_rounded, color: Color(0xFF1DB954)),
    'maps' ||
    'google maps' => (icon: Icons.place_rounded, color: Color(0xFF34A853)),
    _ => null,
  };
}
