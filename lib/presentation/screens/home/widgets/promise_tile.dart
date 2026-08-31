import 'package:flutter/material.dart';

import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../core/utils/reminder_format.dart';
import '../../../../domain/entities/intention.dart';
import '../../../../domain/enums/promise_category.dart';
import '../../promise_detail/widgets/category_picker.dart' show categoryIcon;
import 'reminder_chip.dart';

/// A single row in "Today's Promises": app icon, title, source + time, reminder
/// chip, and a completion toggle (PRD §8.2).
///
/// Stateless and const-friendly: the list rebuilds only the rows whose promise
/// actually changed (PRD §9.1).
class PromiseTile extends StatelessWidget {
  const PromiseTile({
    super.key,
    required this.promise,
    required this.now,
    required this.onToggle,
    this.onTap,
  });

  final Intention promise;
  final DateTime now;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    final done = promise.isResolved;
    final reminder = describeReminder(promise.reminderAt, now);
    final (icon, color) = appVisual(
      promise.sourceApp,
      theme.colorScheme.primary,
    );
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cya.surface2),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      promise.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? cya.textSecondary : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: <Widget>[
                        if (PromiseCategory.fromWire(promise.category)
                            case final category?) ...<Widget>[
                          Icon(
                            categoryIcon(category),
                            size: 13,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            '${promise.sourceApp} · ${reminder.timeLabel}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ReminderChip(display: reminder),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _Toggle(
                key: ValueKey<String>('promise-toggle-${promise.id}'),
                done: done,
                onTap: onToggle,
                title: promise.title,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    super.key,
    required this.done,
    required this.onTap,
    required this.title,
  });

  final bool done;
  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final success = context.cyaColors.success;
    return Semantics(
      button: true,
      checked: done,
      label: done ? 'Mark "$title" as not done' : 'Mark "$title" as done',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // 44dp hit area around a 28dp control (PRD §8.4 tap targets).
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? success : Colors.transparent,
              border: Border.all(
                color: done ? success : colors.outlineVariant,
                width: 2,
              ),
            ),
            child: done
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}

/// Source-app iconography shared by every promise surface.
(IconData, Color) appVisual(String app, Color fallback) {
  return switch (app.toLowerCase()) {
    'messenger' => (Icons.chat_bubble_rounded, const Color(0xFF0084FF)),
    'whatsapp' => (Icons.chat_rounded, const Color(0xFF25D366)),
    'chrome' => (Icons.public_rounded, const Color(0xFF4285F4)),
    'github' => (Icons.code_rounded, const Color(0xFF6E5494)),
    'amazon' => (Icons.shopping_bag_rounded, const Color(0xFFFF9900)),
    'gmail' => (Icons.mail_rounded, const Color(0xFFEA4335)),
    'youtube' => (Icons.play_circle_fill_rounded, const Color(0xFFFF0000)),
    'slack' => (Icons.tag_rounded, const Color(0xFF611F69)),
    'linkedin' => (Icons.work_rounded, const Color(0xFF0A66C2)),
    _ => (Icons.bookmark_rounded, fallback),
  };
}
