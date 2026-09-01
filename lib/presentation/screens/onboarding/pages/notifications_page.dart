import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../core/utils/cya_haptics.dart';
import '../widgets/notification_preview.dart';
import '../widgets/onboarding_page_scaffold.dart';

/// Step 3 — notification permission, asked with its reason on screen.
///
/// PRD §3.5 forbids asking for anything up front and unexplained. The mock
/// reminder above the copy *is* the explanation: this is the thing the
/// permission buys, and "Done" and "Snooze" are visible on it because one-tap
/// resolution from the shade is a V1 invariant (§3.4), not a later nicety.
///
/// "Not now" is a real option and is styled like one. A memory product that
/// coerces a permission out of someone has already broken the tone it spends
/// the rest of its life keeping.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _asking = false;

  Future<void> _ask() async {
    if (_asking) return;
    setState(() => _asking = true);
    CyaHaptics.tap(context);
    // The result is not branched on: granted or refused, the next step is the
    // same, and the reliability screen re-checks the real state anyway.
    await ref.read(reminderPortProvider).ensureNotificationPermission();
    if (!mounted) return;
    setState(() => _asking = false);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageScaffold(
      heroFlex: 4,
      hero: const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: NotificationPreview(),
      ),
      headline: 'This is how I bring things back.',
      body:
          "A promise you can't be reminded of is just a note. At the time you "
          'picked, Cya! posts one quiet notification — with Done and Snooze '
          'right there, so you never have to open the app.',
      supporting: const _Reassurance(),
      primaryLabel: _asking ? 'Waiting for Android…' : 'Allow notifications',
      onPrimary: _asking ? null : _ask,
      secondaryLabel: 'Not now',
      onSecondary: _asking ? null : widget.onNext,
    );
  }
}

class _Reassurance extends StatelessWidget {
  const _Reassurance();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cyaColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Column(
        children: <Widget>[
          _Line(
            icon: Icons.lock_outline_rounded,
            text: 'Only your own promises. Never marketing, never a badge count.',
          ),
          SizedBox(height: AppSpacing.md),
          _Line(
            icon: Icons.nightlight_round,
            text: 'Past the snooze limit it gets quieter, not louder.',
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
      ],
    );
  }
}
