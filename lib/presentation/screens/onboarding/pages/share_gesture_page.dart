import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../widgets/onboarding_page_scaffold.dart';
import '../widgets/share_gesture_demo.dart';

/// Step 2 — the share gesture.
///
/// Non-negotiable (iteration 9, work item 1.2): the product's whole claim is
/// capture in under two seconds from inside another app, and nothing else in
/// the app teaches that this is possible. Without this screen a user opens Cya!
/// to type things in, which is the slow path the product exists to replace.
///
/// No mascot here. This is a demonstration, and a character standing beside the
/// thing being demonstrated competes with it.
class ShareGesturePage extends StatelessWidget {
  const ShareGesturePage({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageScaffold(
      heroFlex: 6,
      hero: const ShareGestureDemo(),
      headline: 'Save it without leaving the app.',
      body:
          'In Messenger, Chrome, Instagram — anywhere — tap Share and pick '
          "Cya!. It's saved before the sheet closes. You never have to open "
          'this app to capture something.',
      supporting: const _SpeedNote(),
      primaryLabel: 'Got it',
      onPrimary: onNext,
    );
  }
}

class _SpeedNote extends StatelessWidget {
  const _SpeedNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: context.cyaColors.surface2,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            Icons.bolt_rounded,
            size: 19,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'No typing. No waiting. Under a second.',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
