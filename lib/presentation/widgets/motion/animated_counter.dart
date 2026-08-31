import 'package:flutter/widgets.dart';

import '../../../core/theme/app_motion.dart';

/// A number that counts to its new value instead of snapping to it.
///
/// Small thing, large effect: when a promise is ticked off, watching "6" roll
/// up to "7" is what makes the count feel *earned*. Snapping makes it feel like
/// a page reload.
///
/// The tween runs on the value, not on the widget tree — one [Text] is rebuilt
/// per frame and nothing around it repaints.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = AppMotion.gentle,
    this.prefix = '',
    this.suffix = '',
  });

  final int value;
  final TextStyle? style;
  final Duration duration;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // Keyed on the target so a change mid-flight retargets from where the
      // number currently is, rather than restarting from the old value.
      tween: Tween<double>(begin: value.toDouble(), end: value.toDouble()),
      duration: AppMotion.of(context, duration),
      curve: AppMotion.enter,
      builder: (context, animated, _) =>
          Text('$prefix${animated.round()}$suffix', style: style),
    );
  }
}

/// A [Text] that cross-fades when its content changes.
///
/// For labels that change meaning rather than magnitude — "3 to go" becoming
/// "all done" — where counting up would be nonsense.
class FadingText extends StatelessWidget {
  const FadingText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.quick),
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      // Both strings are aligned to the leading edge while they cross-fade, so
      // the label grows from its start rather than re-centring mid-transition.
      layoutBuilder: (current, previous) => Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[...previous, ?current],
      ),
      child: Text(
        text,
        key: ValueKey<String>(text),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
