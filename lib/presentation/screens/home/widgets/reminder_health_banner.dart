import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../core/utils/cya_haptics.dart';
import '../../../providers/reminder_providers.dart';

/// Tells the user when reminders are not arriving, and offers the one fix that
/// works (PRD §12).
///
/// It appears only on evidence — a promise whose reminder time passed with no
/// `resurfaced` event, or exact alarms being disallowed — so it is a real
/// warning, not a permission nag. It also *animates* in and out, because a
/// block of amber materialising instantly above the hero card reads as a
/// rendering glitch rather than a message.
class ReminderHealthBanner extends ConsumerWidget {
  const ReminderHealthBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(reminderHealthProvider).valueOrNull;
    final show = health != null && !health.isHealthy;

    return AnimatedSize(
      duration: AppMotion.of(context, AppMotion.gentle),
      curve: AppMotion.standard,
      alignment: Alignment.topCenter,
      child: show
          ? _Banner(health: health)
          : const SizedBox(width: double.infinity),
    );
  }
}

class _Banner extends ConsumerWidget {
  const _Banner({required this.health});

  final ReminderHealth health;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    // The wash keeps the PRD's amber; the icon uses the ink so it survives on
    // a near-white and a near-black surface alike.
    final warning = cya.warning;
    final warningInk = cya.warningInk;
    final missedCount = health.missed.length;
    final message = !health.exactAllowed
        ? 'Android is holding my reminders back, so promises may arrive late.'
        : missedCount == 1
        ? "One promise came due and I couldn't reach you."
        : "$missedCount promises came due and I couldn't reach you.";

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: warning.withValues(alpha: 0.42)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.notifications_off_rounded,
                  size: 20,
                  color: warningInk,
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    'Reminders are being dropped',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => _fix(context, ref),
                child: Text(
                  health.exactAllowed
                      ? 'Re-arm reminders'
                      : 'Let me remind you',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fix(BuildContext context, WidgetRef ref) async {
    CyaHaptics.confirm(context);
    final port = ref.read(reminderPortProvider);
    if (!health.exactAllowed) {
      await port.openExactAlarmSettings();
    } else {
      final count = await port.rescheduleAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('$count reminders re-armed. I have them.')),
          );
      }
    }
    ref.invalidate(reminderHealthProvider);
  }
}
