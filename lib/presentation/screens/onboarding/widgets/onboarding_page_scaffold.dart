import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../widgets/motion/entrance.dart';

/// The shape every onboarding step shares: a hero, a headline, a sentence, and
/// the actions pinned where the thumb already is.
///
/// One scaffold rather than four hand-built screens is what stops step three
/// from drifting 6px away from step two — the flow is read as one motion, and a
/// moving headline baseline is the first thing that breaks that.
///
/// Built on `SliverFillRemaining(hasScrollBody: false)`: the content gets at
/// least the viewport's height so [Spacer] can push the buttons down, and grows
/// into a scroll when a short window or a large text scale needs it. The
/// obvious alternative — `IntrinsicHeight` inside a `SingleChildScrollView` —
/// looks equivalent and is not: it runs an intrinsic-sizing pass, and neither
/// `LayoutBuilder` (the mascot) nor a flexible child answers one.
class OnboardingPageScaffold extends StatelessWidget {
  const OnboardingPageScaffold({
    super.key,
    required this.hero,
    required this.headline,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.heroFlex = 5,
    this.secondaryLabel,
    this.onSecondary,
    this.supporting,
  });

  /// The illustration or demo. Given the top of the screen and the first to
  /// give ground when the window is short.
  final Widget hero;

  /// How much of the free vertical space the hero claims against the text
  /// block. Steps with more to say lower it; a step with no illustration
  /// passes 0.
  final int heroFlex;

  final String headline;
  final String body;

  /// An optional block between the body and the actions — a reassurance card,
  /// a checklist.
  final Widget? supporting;

  final String primaryLabel;
  final VoidCallback? onPrimary;

  /// The quiet way out. Present only on the steps that ask for a permission:
  /// the first two teach the product, and there is nothing there to decline.
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// The tallest a hero may be, in logical pixels.
  static const double _heroMax = 340;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (heroFlex > 0)
                  Flexible(
                    flex: heroFlex,
                    // Capped, not just flexible. A hero sized purely by its
                    // share of free space grows with the screen, and on a tall
                    // phone that pushed the primary action below the fold —
                    // an onboarding step whose CTA has to be scrolled to is
                    // the one thing this scaffold exists to prevent.
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: _heroMax),
                        child: hero,
                      ),
                    ),
                  )
                else
                  hero,
                const SizedBox(height: AppSpacing.xxl),
                Entrance(
                  delay: const Duration(milliseconds: 80),
                  child: Text(headline, style: theme.textTheme.displaySmall),
                ),
                const SizedBox(height: AppSpacing.md),
                Entrance(
                  delay: const Duration(milliseconds: 140),
                  child: Text(
                    body,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: context.cyaColors.textSecondary,
                    ),
                  ),
                ),
                if (supporting case final Widget block) ...<Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  Entrance(
                    delay: const Duration(milliseconds: 200),
                    child: block,
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
                // Takes whatever is left over, and nothing at all once the
                // content has filled the screen.
                const Spacer(),
                FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
                if (secondaryLabel case final String label) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: onSecondary,
                    style: TextButton.styleFrom(
                      foregroundColor: context.cyaColors.textSecondary,
                    ),
                    child: Text(label),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
