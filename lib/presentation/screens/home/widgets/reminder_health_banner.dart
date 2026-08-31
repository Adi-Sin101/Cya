import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../providers/reminder_providers.dart';

/// Tells the user when reminders are not arriving, and offers the one fix that
/// works (PRD §12).
///
/// It appears only on evidence — a promise whose reminder time passed with no
/// `resurfaced` event, or exact alarms being disallowed — so it is a real
/// warning, not a permission nag.
class ReminderHealthBanner extends ConsumerWidget {
  const ReminderHealthBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(reminderHealthProvider).valueOrNull;
    if (health == null || health.isHealthy) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final missedCount = health.missed.length;
    final message = !health.exactAllowed
        ? 'Android is holding my reminders back, so promises may arrive late.'
        : missedCount == 1
        ? "One promise came due and I couldn't reach you."
        : "$missedCount promises came due and I couldn't reach you.";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.notifications_off_rounded,
                  size: 18,
                  color: Color(0xFFB45309),
                ),
                const SizedBox(width: 8),
                Text(
                  'Reminders are being dropped',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(message, style: theme.textTheme.bodySmall),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                FilledButton.tonal(
                  onPressed: () => _fix(context, ref, health),
                  child: Text(
                    health.exactAllowed
                        ? 'Re-arm reminders'
                        : 'Let me remind you',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fix(
    BuildContext context,
    WidgetRef ref,
    ReminderHealth health,
  ) async {
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
