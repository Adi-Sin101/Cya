import 'package:flutter/material.dart';

import '../widgets/onboarding_page_scaffold.dart';

/// Step 1 — what Cya! is, in one sentence and one picture.
///
/// The mascot is allowed here: onboarding is an empathy moment, not the capture
/// path (PRD §8.1). It is also the only step with no decision on it — a first
/// screen that asks for something has already spent trust it has not earned.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageScaffold(
      hero: const _MascotHero(),
      headline: "I'll remember for you.",
      body:
          "You decide 'later' a hundred times a day — a message to reply to, a "
          'video to watch, a paper to read. Cya! catches that moment and brings '
          'it back when it actually matters.',
      primaryLabel: 'Next',
      onPrimary: onNext,
    );
  }
}

class _MascotHero extends StatelessWidget {
  const _MascotHero();

  /// The logo asset is a square with its own near-white background, so it
  /// cannot simply be dropped onto a coloured circle — it reads as a white box.
  /// The splash solves this by matching the circle to the asset's ground; this
  /// does the same, then sets that disc on the mint blob the design system
  /// calls for.
  static const Color _assetGround = Color(0xFFFDFBF9);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Sized by aspect ratio rather than by a LayoutBuilder: the onboarding
    // scaffold measures its content's intrinsic height, and a LayoutBuilder has
    // no intrinsics to give it.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.secondaryContainer,
          ),
          child: Padding(
            // Inset to the blob's inscribed square, so the square artwork sits
            // wholly inside the disc instead of clipping at its edges.
            padding: const EdgeInsets.all(22),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _assetGround,
              ),
              child: ClipOval(
                child: Image.asset(
                  'lib/assets/images/cya-logo.png',
                  fit: BoxFit.cover,
                  semanticLabel: 'Cya, the beaver who remembers for you',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
