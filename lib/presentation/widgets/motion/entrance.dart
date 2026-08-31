import 'package:flutter/widgets.dart';

import '../../../core/theme/app_motion.dart';

/// Fades and lifts a widget into place once, on first build.
///
/// Used to give a screen a sense of arrival rather than a hard cut. [delay]
/// staggers siblings so a list assembles itself top-down; see [staggered] for
/// the common case.
///
/// Under reduced motion this renders its finished state immediately and never
/// starts a controller (PRD §8.3) — a still UI, not a fast one.
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.slow,
    this.offset = 18,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// How far below its resting place the child starts, in logical pixels.
  final double offset;

  /// Wraps [children] in [Entrance]es, each one [step] later than the last.
  ///
  /// The stagger is capped: past a handful of items the delay stops reading as
  /// rhythm and starts reading as lag, so later items all arrive together.
  static List<Widget> staggered(
    List<Widget> children, {
    Duration step = AppMotion.stagger,
    int maxSteps = 7,
  }) {
    return <Widget>[
      for (var i = 0; i < children.length; i++)
        Entrance(
          delay: step * (i < maxSteps ? i : maxSteps),
          child: children[i],
        ),
    ];
  }

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.isReduced(context)) {
      _controller.value = 1;
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      // The child is built once and reused across every frame of the
      // animation — only the opacity and transform change (PRD §9.1).
      child: widget.child,
      builder: (context, child) {
        final t = AppMotion.enter.transform(_controller.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}
