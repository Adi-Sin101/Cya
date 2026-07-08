import 'package:flutter/material.dart';

import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../domain/models/promise.dart';
import 'preset_chip.dart';

/// A single row in "Today's Promises": app icon, title, source + time, preset
/// chip, and a completion toggle (PRD §8.2).
class PromiseTile extends StatelessWidget {
  const PromiseTile({super.key, required this.promise, required this.onToggle});

  final Promise promise;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    final done = promise.isCompleted;
    final (icon, color) = _appVisual(
      promise.sourceApp,
      theme.colorScheme.primary,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
                    Flexible(
                      child: Text(
                        '${promise.sourceApp} · ${promise.timeLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PresetChip(preset: promise.preset),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _Toggle(done: done, onTap: onToggle),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final success = context.cyaColors.success;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
    );
  }
}

(IconData, Color) _appVisual(String app, Color fallback) {
  return switch (app.toLowerCase()) {
    'messenger' => (Icons.chat_bubble_rounded, const Color(0xFF0084FF)),
    'chrome' => (Icons.public_rounded, const Color(0xFF4285F4)),
    'github' => (Icons.code_rounded, const Color(0xFF6E5494)),
    'amazon' => (Icons.shopping_bag_rounded, const Color(0xFFFF9900)),
    _ => (Icons.bookmark_rounded, fallback),
  };
}
