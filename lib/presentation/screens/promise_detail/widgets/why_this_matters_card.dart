import 'package:flutter/material.dart';

import '../../../../domain/entities/intention.dart';
import '../../../../domain/policies/snooze_policy.dart';

/// The "Why this matters" empathy card with the mascot (PRD §8.2, §8.3).
///
/// The mascot appears here — a reward/empathy surface — and never on the
/// capture path (PRD §3.6/§8.1).
class WhyThisMattersCard extends StatelessWidget {
  const WhyThisMattersCard({
    super.key,
    required this.promise,
    required this.now,
  });

  final Intention promise;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFA7D7C5), Color(0xFF74B69D)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('🦫', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Why this matters',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _message(promise, now),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF14532D).withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Speaks to what actually happened to this promise — how long it has waited
/// and how often it has been pushed back — rather than generic encouragement.
String _message(Intention promise, DateTime now) {
  if (promise.isResolved) {
    return 'Done. That is one more thing future you does not have to carry.';
  }
  final waitedDays = now.difference(promise.capturedAt).inDays;
  if (SnoozePolicy.requiresResolutionPrompt(promise)) {
    return 'This has come back ${promise.snoozeCount} times. If it still '
        'matters, two minutes now beats another week of carrying it.';
  }
  if (promise.snoozeCount > 0) {
    return 'You pushed this back ${promise.snoozeCount} '
        '${promise.snoozeCount == 1 ? 'time' : 'times'} already — I kept it '
        'anyway. Want to finish it now?';
  }
  if (waitedDays >= 7) {
    return 'You saved this $waitedDays days ago and meant it then. '
        'I remembered so you did not have to.';
  }
  return 'You decided this was worth coming back to. '
      "I'll keep holding it until you're ready.";
}
