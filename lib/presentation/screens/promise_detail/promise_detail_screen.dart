import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/result.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/cya_haptics.dart';
import '../../../core/utils/reminder_format.dart';
import '../../../domain/entities/intention.dart';
import '../../../domain/enums/promise_category.dart';
import '../../../domain/policies/snooze_policy.dart';
import '../../providers/intention_providers.dart';
import '../../widgets/motion/entrance.dart';
import '../../widgets/motion/reward_burst.dart';
import '../../widgets/source_avatar.dart';
import '../home/widgets/reminder_chip.dart';
import 'widgets/category_picker.dart';
import 'widgets/reply_draft_card.dart';
import 'widgets/snooze_sheet.dart';
import 'widgets/why_this_matters_card.dart';

/// Promise detail / resurface (PRD §8.2).
///
/// This is the screen a reminder opens, so the three actions that close the
/// loop — done, open the source app, snooze — are the first thing in reach
/// (PRD §3.4). Everything supporting sits above them, quieter.
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
          const SizedBox(width: AppSpacing.sm),
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
    CyaHaptics.warn(context);
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.section,
      ),
      children: Entrance.staggered(<Widget>[
        // The title is the screen. It gets the largest type here and no
        // competition — a promise you opened from a notification should be
        // legible before you have focused on it.
        Text(promise.title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            SourceAvatar(
              sourceApp: promise.sourceApp,
              sourcePackage: promise.sourcePackage,
              size: 28,
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Text(
                '${promise.sourceApp} · ${formatDay(promise.capturedAt)}, '
                '${formatTimeOfDay(promise.capturedAt)}',
                style: theme.textTheme.labelMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            ReminderChip(display: reminder),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                reminder.kind == ReminderKind.none
                    ? 'No reminder set'
                    : reminder.timeLabel,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Actions come before the supporting detail: this screen is opened to
        // *act*, not to read (PRD §3.4).
        _Actions(promise: promise),
        const SizedBox(height: AppSpacing.xxl),

        // The captured text is only worth its own card when there is more of
        // it than the title already showed.
        if (promise.rawContent.trim() != promise.title.trim()) ...<Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cya.surface2,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('What you saved', style: theme.textTheme.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                SelectableText(
                  promise.rawContent,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        CategoryPicker(
          selected: PromiseCategory.fromWire(promise.category),
          onChanged: (category) async {
            await ref
                .read(manageIntentionProvider)
                .categorize(promise.id, category?.wire);
            if (context.mounted) CyaHaptics.confirm(context);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        if (!promise.isResolved && ReplyDraftCard.suits(promise)) ...<Widget>[
          ReplyDraftCard(promise: promise),
          const SizedBox(height: AppSpacing.md),
        ],
        WhyThisMattersCard(promise: promise, now: now),
      ]),
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
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: promise.deepLink == null
                    ? null
                    : () => _openSource(context, ref),
                icon: const Icon(Icons.open_in_new_rounded, size: 20),
                label: Text(
                  'Open in ${promise.sourceApp}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: done ? null : () => _snooze(context, ref),
                icon: const Icon(Icons.snooze_rounded, size: 20),
                label: const Text('Snooze'),
              ),
            ),
          ],
        ),
        if (SnoozePolicy.requiresResolutionPrompt(promise)) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.cyaColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.flag_rounded,
                      size: 20,
                      color: context.cyaColors.warningInk,
                    ),
                    const SizedBox(width: AppSpacing.sm + 2),
                    Expanded(
                      child: Text(
                        "You've pushed this back ${promise.snoozeCount} times.",
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Finish it, or let it go — no guilt either way.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () => _archive(context, ref),
                  icon: const Icon(Icons.inventory_2_outlined, size: 20),
                  label: const Text('Let it go (archive)'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final wasResolved = promise.isResolved;
    if (wasResolved) {
      CyaHaptics.tap(context);
    } else {
      CyaHaptics.celebrate(context);
    }
    final result = await ref.read(resolveIntentionProvider).toggle(promise.id);
    if (!context.mounted) return;
    if (result.errorOrNull case final AppError error) {
      _snack(context, error.message);
      return;
    }
    if (!wasResolved) {
      showRewardBurst(context, seed: promise.id);
      _snack(context, 'Kept ✨');
    }
  }

  Future<void> _snooze(BuildContext context, WidgetRef ref) async {
    CyaHaptics.tap(context);
    final choice = await showSnoozeSheet(context);
    if (choice == null || !context.mounted) return;
    final result = await ref
        .read(snoozeIntentionProvider)
        .call(promise.id, by: choice);
    if (!context.mounted) return;
    result.fold(
      (target) {
        CyaHaptics.confirm(context);
        _snack(
          context,
          'Back at ${describeReminder(target, ref.read(clockProvider)()).timeLabel}',
        );
      },
      (error) {
        CyaHaptics.warn(context);
        _snack(context, error.message);
      },
    );
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(manageIntentionProvider).archive(promise.id);
    if (!context.mounted) return;
    result.fold((_) {
      CyaHaptics.confirm(context);
      _snack(context, 'Let go. That is allowed.');
    }, (error) => _snack(context, error.message));
  }

  Future<void> _openSource(BuildContext context, WidgetRef ref) async {
    final link = promise.deepLink;
    if (link == null) return;
    CyaHaptics.tap(context);
    final opened = await ref.read(reminderPortProvider).openLink(link);
    if (!context.mounted || opened) return;
    // Say what happened rather than failing silently (PRD §13.4).
    _snack(context, "Nothing on this device can open that link.");
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
        padding: const EdgeInsets.all(AppSpacing.section),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('🦫', style: TextStyle(fontSize: 44)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'That promise is no longer here.',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
