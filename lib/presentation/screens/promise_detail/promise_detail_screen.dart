import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/result.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/reminder_format.dart';
import '../../../domain/entities/intention.dart';
import '../../../domain/policies/snooze_policy.dart';
import '../../providers/intention_providers.dart';
import '../home/widgets/promise_tile.dart' show appVisual;
import '../home/widgets/reminder_chip.dart';
import 'widgets/snooze_sheet.dart';
import 'widgets/why_this_matters_card.dart';

/// Promise detail / resurface (PRD §8.2).
///
/// This is the screen a reminder opens, so the three actions that close the
/// loop — done, open the source app, snooze — are the first thing in reach
/// (PRD §3.4).
class PromiseDetailScreen extends ConsumerWidget {
  const PromiseDetailScreen({super.key, required this.intentionId});

  final int? intentionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = intentionId;
    if (id == null) return const _MissingPromise();

    final promise = ref.watch(intentionByIdProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promise'),
        actions: <Widget>[
          if (promise.valueOrNull != null)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _confirmDelete(context, ref, id),
            ),
        ],
      ),
      body: promise.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, _) => Center(child: Text('$error')),
        data: (value) => value == null
            ? const _MissingPromise()
            : _PromiseBody(promise: value),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this promise?'),
        content: const Text(
          'It disappears for good, along with its history. '
          'Cya! keeps nothing you delete.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(manageIntentionProvider).delete(id);
    if (context.mounted) context.pop();
  }
}

class _PromiseBody extends ConsumerWidget {
  const _PromiseBody({required this.promise});

  final Intention promise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    final now = ref.watch(clockProvider)();
    final reminder = describeReminder(promise.reminderAt, now);
    final (icon, color) = appVisual(
      promise.sourceApp,
      theme.colorScheme.primary,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(promise.title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    '${promise.sourceApp} · captured '
                    '${formatDay(promise.capturedAt)}, '
                    '${formatTimeOfDay(promise.capturedAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            ReminderChip(display: reminder),
            const SizedBox(width: 8),
            Text(
              reminder.kind == ReminderKind.none
                  ? 'No reminder set'
                  : '${reminder.chipLabel} · ${reminder.timeLabel}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cya.surface2,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('What you saved', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SelectableText(
                promise.rawContent,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        WhyThisMattersCard(promise: promise, now: now),
        const SizedBox(height: 24),
        _Actions(promise: promise),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.promise});

  final Intention promise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final done = promise.isResolved;
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _toggle(context, ref),
            icon: Icon(done ? Icons.undo_rounded : Icons.check_circle_rounded),
            label: Text(done ? 'Mark as not done' : 'Mark as Done'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: promise.deepLink == null
                    ? null
                    : () => _openSource(context),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text('Open in ${promise.sourceApp}'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: done ? null : () => _snooze(context, ref),
                icon: const Icon(Icons.snooze_rounded),
                label: const Text('Snooze'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
        if (SnoozePolicy.requiresResolutionPrompt(promise)) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.flag_rounded, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "You've pushed this back ${promise.snoozeCount} times. "
                    'Finish it, or let it go — no guilt either way.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _archive(context, ref),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Let it go (archive)'),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(resolveIntentionProvider).toggle(promise.id);
    if (!context.mounted) return;
    _report(context, result, success: promise.isResolved ? null : 'Kept ✨');
  }

  Future<void> _snooze(BuildContext context, WidgetRef ref) async {
    final choice = await showSnoozeSheet(context);
    if (choice == null || !context.mounted) return;
    final result = await ref
        .read(snoozeIntentionProvider)
        .call(promise.id, by: choice);
    if (!context.mounted) return;
    result.fold(
      (target) => _snack(
        context,
        'Back at ${describeReminder(target, DateTime.now()).timeLabel}',
      ),
      (error) => _snack(context, error.message),
    );
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(manageIntentionProvider).archive(promise.id);
    if (!context.mounted) return;
    _report(context, result, success: 'Let go. That is allowed.');
  }

  void _openSource(BuildContext context) {
    // Deep-link handoff is part of the native capture work; until then, say so
    // rather than pretending (PRD §13.4 — no silent no-ops).
    _snack(context, 'Return-to-app arrives with the native capture path.');
  }

  void _report(BuildContext context, Result<void> result, {String? success}) {
    result.fold((_) {
      if (success != null) _snack(context, success);
    }, (error) => _snack(context, error.message));
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MissingPromise extends StatelessWidget {
  const _MissingPromise();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('🦫', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'That promise is no longer here.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
