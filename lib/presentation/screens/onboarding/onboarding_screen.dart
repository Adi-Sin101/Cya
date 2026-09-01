import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/cya_haptics.dart';
import 'pages/notifications_page.dart';
import 'pages/reliability_page.dart';
import 'pages/share_gesture_page.dart';
import 'pages/welcome_page.dart';

/// The four steps a new install sees, in order (iteration 9, work item 1).
///
/// Ordering is the design: teach what this is, teach the gesture the product
/// depends on, *then* ask for a permission, and only then walk the OEM
/// settings. Every ask arrives after the reason for it is on screen (PRD §3.5).
///
/// There is no global "skip". The two teaching steps have nothing to decline,
/// and the two asking steps carry their own quiet way past — which is a
/// different thing from a skip link that lets someone leave without ever
/// learning the share sheet, the one failure this flow exists to prevent.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pages = PageController();
  int _index = 0;

  static const int _stepCount = 4;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    CyaHaptics.selection(context);
    if (_index >= _stepCount - 1) return;
    if (AppMotion.isReduced(context)) {
      _pages.jumpToPage(_index + 1);
    } else {
      _pages.nextPage(
        duration: AppMotion.gentle,
        curve: AppMotion.standard,
      );
    }
  }

  /// Onboarding ends at the profile, not at Home: a name and an avatar are the
  /// last thing set up, and the greeting on Home then already knows who it is
  /// talking to.
  void _finish() {
    CyaHaptics.confirm(context);
    context.go(RoutePaths.profileSetup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _pages,
                // Swiping is allowed forward and back — the flow is a story,
                // and a reader may want the previous page again.
                onPageChanged: (index) => setState(() => _index = index),
                children: <Widget>[
                  WelcomePage(onNext: _next),
                  ShareGesturePage(onNext: _next),
                  NotificationsPage(onNext: _next),
                  ReliabilityPage(onFinish: _finish),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: AppSpacing.lg,
              ),
              child: _StepDots(count: _stepCount, index: _index),
            ),
          ],
        ),
      ),
    );
  }
}

/// Where you are in the flow. The active step is a stretched pill rather than a
/// bigger dot, so position is legible without counting.
class _StepDots extends StatelessWidget {
  const _StepDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Step ${index + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppMotion.of(context, AppMotion.quick),
              curve: AppMotion.standard,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              width: i == index ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == index
                    ? theme.colorScheme.primary
                    : context.cyaColors.surface2,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}
