import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';

/// A mock of the reminder Cya! will actually post.
///
/// Shown *before* the permission dialog, because a system prompt with no
/// context is a coin flip: this is what "allow notifications" buys, drawn to
/// scale, Done and Snooze included (PRD §3.4, §3.5).
///
/// Two cards, stacked — the second one peeking is how ADR-012's grouping reads
/// in the shade, and it quietly promises six promises will not become six
/// notifications.
class NotificationPreview extends StatelessWidget {
  const NotificationPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'A preview of a Cya! reminder notification for "Reply to Sarah", '
          'with Done and Snooze actions.',
      excludeSemantics: true,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          // The one behind, implying the group rather than drawing all of it.
          Padding(
            padding: const EdgeInsets.only(top: 26),
            child: FractionallySizedBox(
              widthFactor: 0.88,
              child: Opacity(
                opacity: 0.45,
                child: IgnorePointer(child: _Card(dimmed: true)),
              ),
            ),
          ),
          Transform.rotate(angle: -0.018, child: _Card(dimmed: false)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.dimmed});

  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cya = context.cyaColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: dimmed ? null : cyaShadow(context, elevation: 1.6),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(Icons.eco_rounded, size: 12, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Cya! · now',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cya.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Reply to Sarah', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'from Messenger · saved 6h ago',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cya.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: colors.outlineVariant),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              _Action(icon: Icons.check_rounded, label: 'Done'),
              const SizedBox(width: AppSpacing.xl),
              _Action(icon: Icons.schedule_rounded, label: 'Snooze'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.xs + 2),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
