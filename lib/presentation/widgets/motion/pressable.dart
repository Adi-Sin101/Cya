import 'package:flutter/widgets.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/utils/cya_haptics.dart';

/// A tap target that physically responds: it shrinks under the finger, springs
/// back on release, and fires a haptic (PRD §8.3).
///
/// This exists because Material's ink ripple is the wrong feedback for a card.
/// A ripple says "a surface was touched"; a scale says "this object moved
/// because you pushed it", which is what a promise tile, a stat card or a
/// gradient panel actually is. Ink is still right for list rows inside a
/// [Material] — use this for the standalone, card-shaped things.
///
/// The press-down is deliberately faster than the release: real objects give
/// instantly and settle slowly.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.97,
    this.haptic = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// How far down it presses. Subtle on purpose — a big card scaling 0.9 looks
  /// like it broke.
  final double scale;

  final bool haptic;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.instant,
    reverseDuration: AppMotion.quick,
  );

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) {
    if (!_enabled || AppMotion.isReduced(context)) return;
    _controller.forward();
  }

  void _up([TapUpDetails? _]) => _controller.reverse();

  void _tap() {
    if (widget.haptic) CyaHaptics.tap(context);
    widget.onTap?.call();
  }

  void _longPress() {
    if (widget.onLongPress == null) return;
    if (widget.haptic) CyaHaptics.confirm(context);
    widget.onLongPress!.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: _enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _down,
        onTapUp: _up,
        onTapCancel: _up,
        onTap: _enabled ? _tap : null,
        onLongPress: widget.onLongPress == null ? null : _longPress,
        child: AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (context, child) => Transform.scale(
            scale:
                1 -
                (1 - widget.scale) *
                    AppMotion.standard.transform(_controller.value),
            child: child,
          ),
        ),
      ),
    );
  }
}
