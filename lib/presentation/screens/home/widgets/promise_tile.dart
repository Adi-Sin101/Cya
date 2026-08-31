import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../core/utils/cya_haptics.dart';
import '../../../../core/utils/reminder_format.dart';
import '../../../../domain/entities/intention.dart';
import '../../../../domain/enums/promise_category.dart';
import '../../../widgets/source_avatar.dart';
import '../../promise_detail/widgets/category_picker.dart' show categoryIcon;
import 'reminder_chip.dart';

/// A single row in "Today's Promises": app icon, title, source + time, reminder
/// chip, and a completion toggle (PRD §8.2).
///
/// Stateless and const-friendly: the list rebuilds only the rows whose promise
/// actually changed (PRD §9.1).
///
/// The row was carrying four competing pieces of metadata under the title
/// (category icon, source app, absolute time, reminder chip). Three of them
/// said roughly the same thing. The chip already names *when*, so the line
/// underneath is now just where it came from — the title gets the room back.
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
    final done = promise.isResolved;
    final reminder = describeReminder(promise.reminderAt, now);
    final category = PromiseCategory.fromWire(promise.category);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                CyaHaptics.tap(context);
                onTap!();
              },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: <Widget>[
              // The source badge fades back once a promise is done: the row is
              // still readable, but it stops asking to be looked at.
              SourceAvatar(
                sourceApp: promise.sourceApp,
                sourcePackage: promise.sourcePackage,
                dimmed: done,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AnimatedDefaultTextStyle(
                      duration: AppMotion.of(context, AppMotion.quick),
                      style:
                          theme.textTheme.titleSmall?.copyWith(
                            decoration: done
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: context.cyaColors.textSecondary,
                            color: done
                                ? context.cyaColors.textSecondary
                                : theme.colorScheme.onSurface,
                          ) ??
                          const TextStyle(),
                      child: Text(
                        promise.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: <Widget>[
                        ReminderChip(display: reminder),
                        const SizedBox(width: AppSpacing.sm),
                        if (category != null) ...<Widget>[
                          Icon(
                            categoryIcon(category),
                            size: 14,
                            color: context.cyaColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Flexible(
                          child: Text(
                            promise.sourceApp,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              PromiseToggle(
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

/// The completion toggle.
///
/// Ticking a promise is the moment the product exists for, so it gets more
/// care than a checkbox usually would: the ring fills, the check draws itself
/// in from nothing, and the whole control overshoots once before settling. The
/// haptic is [CyaHaptics.celebrate] on the way in and a plain tap on the way
/// out — undoing something should not feel like an achievement.
class PromiseToggle extends StatefulWidget {
  const PromiseToggle({
    super.key,
    required this.done,
    required this.onTap,
    required this.title,
  });

  final bool done;
  final VoidCallback onTap;
  final String title;

  @override
  State<PromiseToggle> createState() => _PromiseToggleState();
}

class _PromiseToggleState extends State<PromiseToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.gentle,
    value: widget.done ? 1 : 0,
  );

  @override
  void didUpdateWidget(PromiseToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.done == oldWidget.done) return;
    if (AppMotion.isReduced(context)) {
      _controller.value = widget.done ? 1 : 0;
    } else if (widget.done) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tap() {
    if (widget.done) {
      CyaHaptics.tap(context);
    } else {
      CyaHaptics.celebrate(context);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final success = context.cyaColors.success;

    return Semantics(
      button: true,
      checked: widget.done,
      label: widget.done
          ? 'Mark "${widget.title}" as not done'
          : 'Mark "${widget.title}" as done',
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: _tap,
          behavior: HitTestBehavior.opaque,
          // 48dp hit area around a 30dp control (PRD §8.4 tap targets).
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm + 1),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                final pop = AppMotion.grow.transform(t.clamp(0.0, 1.0));
                return Transform.scale(
                  scale: 1 + 0.12 * (pop * (1 - pop) * 4),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(Colors.transparent, success, t),
                      border: Border.all(
                        color: Color.lerp(colors.outlineVariant, success, t)!,
                        width: 2,
                      ),
                    ),
                    child: t <= 0.01
                        ? null
                        : CustomPaint(painter: _CheckPainter(progress: t)),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws the tick as a stroke that grows along its own path, so the check
/// arrives *written* rather than pasted.
class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final start = Offset(w * 0.27, h * 0.52);
    final elbow = Offset(w * 0.44, h * 0.68);
    final end = Offset(w * 0.74, h * 0.34);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // The short leg is drawn over the first 40% of the animation, the long one
    // over the rest — which is roughly how a hand draws a tick.
    final t = progress.clamp(0.0, 1.0);
    if (t <= 0.4) {
      canvas.drawLine(start, Offset.lerp(start, elbow, t / 0.4)!, paint);
      return;
    }
    canvas.drawPath(
      Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(elbow.dx, elbow.dy)
        ..lineTo(
          Offset.lerp(elbow, end, (t - 0.4) / 0.6)!.dx,
          Offset.lerp(elbow, end, (t - 0.4) / 0.6)!.dy,
        ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
