import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/result.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../domain/entities/intention.dart';
import '../../../domain/enums/intention_status.dart';
import '../../../domain/policies/snooze_policy.dart';
import '../../providers/intention_providers.dart';
import '../../widgets/motion/entrance.dart';
import '../../widgets/motion/reward_burst.dart';
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
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.section,
        ),
        children: <Widget>[
          Entrance(
            child: _KeptCard(kept: week.completed, captured: week.captured),
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (stalled.isNotEmpty) ...<Widget>[
            Text('Time to decide', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "You've pushed these back as far as I'll let you. "
              'Finish them, or let them go — both are fine.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final promise in stalled)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: PromiseTile(
                  key: ValueKey<int>(promise.id),
                  promise: promise,
                  now: now,
                  onToggle: () => _toggle(context, ref, promise),
                  onTap: () =>
                      context.push(RoutePaths.promiseDetail(promise.id)),
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          Text('Still waiting', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          if (waiting.isEmpty)
            Text(
              'Nothing is waiting. That is a rare and good thing.',
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final promise in waiting)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: PromiseTile(
                  key: ValueKey<int>(promise.id),
                  promise: promise,
                  now: now,
                  onToggle: () => _toggle(context, ref, promise),
                  onTap: () =>
                      context.push(RoutePaths.promiseDetail(promise.id)),
                ),
              ),
          if (kept.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xxl),
            Text('Kept', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            for (final promise in kept.take(10))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: PromiseTile(
                  key: ValueKey<int>(promise.id),
                  promise: promise,
                  now: now,
                  onToggle: () => _toggle(context, ref, promise),
                  onTap: () =>
                      context.push(RoutePaths.promiseDetail(promise.id)),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    Intention promise,
  ) async {
    final wasResolved = promise.isResolved;
    final result = await ref.read(resolveIntentionProvider).toggle(promise.id);
    if (!context.mounted) return;
    if (result.errorOrNull case final AppError error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }
    if (!wasResolved) showRewardBurst(context, seed: promise.id);
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        // Sage through most of the card so the white copy keeps a 5.9:1 field
        // (PRD §8.4); the soft-sage end carries no text.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.sage, AppColors.sage, AppColors.softSage],
          stops: <double>[0, 0.55, 1],
        ),
        boxShadow: cyaShadow(context),
      ),
      child: Row(
        children: <Widget>[
          const Text('🦫', style: TextStyle(fontSize: 38)),
          const SizedBox(width: AppSpacing.lg),
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
                const SizedBox(height: AppSpacing.xs + 2),
                Text(
                  kept == 0
                      ? "Nothing finished — and nothing lost. I still have it all."
                      : 'out of $captured you captured this week.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
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
