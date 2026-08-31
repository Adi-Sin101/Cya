import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/result.dart';
import '../../../core/router/route_paths.dart';
import '../../../domain/entities/intention.dart';
import '../../../domain/enums/intention_status.dart';
import '../../../domain/policies/snooze_policy.dart';
import '../../providers/intention_providers.dart';
import '../home/widgets/promise_tile.dart';

/// The weekly review (PRD §5.6) — and the home escalation's third rung points
/// at: a promise pushed past the snooze limit stops interrupting and waits here.
///
/// It opens with what the user *kept*. A review that leads with failures is how
/// a memory product becomes the backlog it was meant to prevent (§12).
class DigestScreen extends ConsumerWidget {
  const DigestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final week = ref.watch(weekStatsProvider);
    final all =
        ref.watch(allIntentionsProvider).valueOrNull ?? const <Intention>[];

    final open = all.where((p) => p.status.isPending).toList()
      ..sort((a, b) => (a.reminderAt ?? now).compareTo(b.reminderAt ?? now));
    final stalled = open.where(SnoozePolicy.requiresResolutionPrompt).toList();
    final waiting = open
        .where((p) => !SnoozePolicy.requiresResolutionPrompt(p))
        .toList();
    final kept = all
        .where((p) => p.status == IntentionStatus.resolved)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your week')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          _KeptCard(kept: week.completed, captured: week.captured),
          const SizedBox(height: 24),
          if (stalled.isNotEmpty) ...<Widget>[
            Text('Time to decide', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              "You've pushed these back as far as I'll let you. "
              'Finish them, or let them go — both are fine.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            for (final promise in stalled)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PromiseTile(
                  key: ValueKey<int>(promise.id),
                  promise: promise,
                  now: now,
                  onToggle: () => _toggle(context, ref, promise.id),
                  onTap: () =>
                      context.push(RoutePaths.promiseDetail(promise.id)),
                ),
              ),
            const SizedBox(height: 24),
          ],
          Text('Still waiting', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          if (waiting.isEmpty)
            Text(
              'Nothing is waiting. That is a rare and good thing.',
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final promise in waiting)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PromiseTile(
                  key: ValueKey<int>(promise.id),
                  promise: promise,
                  now: now,
                  onToggle: () => _toggle(context, ref, promise.id),
                  onTap: () =>
                      context.push(RoutePaths.promiseDetail(promise.id)),
                ),
              ),
          if (kept.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            Text('Kept', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final promise in kept.take(10))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PromiseTile(
                  key: ValueKey<int>(promise.id),
                  promise: promise,
                  now: now,
                  onToggle: () => _toggle(context, ref, promise.id),
                  onTap: () =>
                      context.push(RoutePaths.promiseDetail(promise.id)),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, int id) async {
    final result = await ref.read(resolveIntentionProvider).toggle(id);
    if (!context.mounted) return;
    if (result.errorOrNull case final AppError error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _KeptCard extends StatelessWidget {
  const _KeptCard({required this.kept, required this.captured});

  final int kept;
  final int captured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF2E705B), Color(0xFF74B69D)],
        ),
      ),
      child: Row(
        children: <Widget>[
          const Text('🦫', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  kept == 0
                      ? 'A quiet week'
                      : kept == 1
                      ? 'You kept 1 promise'
                      : 'You kept $kept promises',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kept == 0
                      ? "Nothing finished — and nothing lost. I still have it all."
                      : 'out of $captured you captured this week.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
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
