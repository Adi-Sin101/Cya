import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../core/utils/cya_haptics.dart';

/// How many digits a Cya! PIN has.
///
/// Four, not six. The threat here is a flatmate picking up an unlocked phone,
/// not a forensics lab, and every extra digit is friction on a screen the user
/// crosses before they can read a message they already saved. Depth comes from
/// the stretched hash and the failed-attempt cooldown instead — see `PinHasher`
/// and `PreferenceLockRepository`.
const int kPinLength = 4;

/// The filled/hollow dots above the keypad.
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.entered,
    this.length = kPinLength,
    this.shake = false,
  });

  final int entered;
  final int length;

  /// Set on a rejected PIN. The row shifts once and settles — the only piece of
  /// negative feedback in the app that is allowed to move, because there is no
  /// text to read at the moment a PIN is wrong.
  final bool shake;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (var i = 0; i < length; i++)
          AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.instant),
            curve: AppMotion.standard,
            margin: const EdgeInsets.symmetric(horizontal: 9),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < entered ? theme.colorScheme.primary : null,
              border: i < entered
                  ? null
                  : Border.all(color: theme.colorScheme.outlineVariant, width: 2),
            ),
          ),
      ],
    );

    return Semantics(
      label: '$entered of $length digits entered',
      excludeSemantics: true,
      child: _Shake(active: shake, child: row),
    );
  }
}

class _Shake extends StatefulWidget {
  const _Shake({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_Shake> createState() => _ShakeState();
}

class _ShakeState extends State<_Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  @override
  void didUpdateWidget(_Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active && !AppMotion.isReduced(context)) {
      _controller.forward(from: 0);
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
      child: widget.child,
      builder: (context, child) {
        // A damped oscillation: three decreasing swings, then still.
        final t = _controller.value;
        final offset = t == 0
            ? 0.0
            : 10 * (1 - t) * _sinTurns(t * 3);
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
    );
  }

  static double _sinTurns(double turns) {
    // Cheap sine over turns without importing dart:math into a build path.
    final phase = (turns % 1.0) * 4;
    return switch (phase) {
      < 1 => phase,
      < 3 => 2 - phase,
      _ => phase - 4,
    };
  }
}

/// The numeric keypad.
///
/// Custom rather than the system keyboard: a PIN pad has to be reachable with
/// one thumb, must not offer autocorrect or a paste target, and must not resize
/// the screen when it opens. Keys are 72dp circles — well past the 48dp floor
/// (PRD §8.4), because this is a control people use without looking.
class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onBiometric,
    this.enabled = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  /// Shown in the bottom-left cell when a fingerprint is available. Absent on
  /// the setup screen, where there is nothing yet to unlock.
  final VoidCallback? onBiometric;

  /// False during a cooldown or while a PIN is being checked.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final row in const <List<String>>[
          <String>['1', '2', '3'],
          <String>['4', '5', '6'],
          <String>['7', '8', '9'],
        ])
          _Row(
            children: <Widget>[
              for (final digit in row)
                _DigitKey(
                  digit: digit,
                  enabled: enabled,
                  onTap: () => onDigit(digit),
                ),
            ],
          ),
        _Row(
          children: <Widget>[
            if (onBiometric case final VoidCallback authenticate)
              _IconKey(
                icon: Icons.fingerprint_rounded,
                semanticLabel: 'Unlock with fingerprint',
                enabled: enabled,
                onTap: authenticate,
              )
            else
              const SizedBox.square(dimension: _keySize),
            _DigitKey(digit: '0', enabled: enabled, onTap: () => onDigit('0')),
            _IconKey(
              icon: Icons.backspace_outlined,
              semanticLabel: 'Delete last digit',
              enabled: enabled,
              onTap: onBackspace,
            ),
          ],
        ),
      ],
    );
  }
}

const double _keySize = 72;

class _Row extends StatelessWidget {
  const _Row({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (final child in children)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _DigitKey extends StatelessWidget {
  const _DigitKey({
    required this.digit,
    required this.enabled,
    required this.onTap,
  });

  final String digit;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _KeySurface(
      enabled: enabled,
      filled: true,
      semanticLabel: digit,
      onTap: onTap,
      child: Text(
        digit,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _IconKey extends StatelessWidget {
  const _IconKey({
    required this.icon,
    required this.semanticLabel,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _KeySurface(
      enabled: enabled,
      filled: false,
      semanticLabel: semanticLabel,
      onTap: onTap,
      child: Icon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
    );
  }
}

class _KeySurface extends StatelessWidget {
  const _KeySurface({
    required this.enabled,
    required this.filled,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final bool enabled;
  final bool filled;
  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Material(
          color: filled ? context.cyaColors.surface2 : Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled
                ? () {
                    CyaHaptics.tap(context);
                    onTap();
                  }
                : null,
            child: SizedBox.square(
              dimension: _keySize,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
