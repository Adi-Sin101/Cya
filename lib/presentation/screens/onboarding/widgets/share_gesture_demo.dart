import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';

/// A looping demonstration of the one gesture the product depends on: share
/// from another app into Cya!.
///
/// This is the highest-value pixel in the app. Nothing else teaches the share
/// sheet, and a user who never finds it experiences Cya! as a notes app with
/// extra steps. So it is shown rather than described — a phone inside the
/// phone, a real share sheet rising, the Cya! target lighting up, and the save
/// confirmed before the sheet has finished closing.
///
/// Drawn with composited widgets rather than a video or a Rive file: it has to
/// re-colour itself for the dark theme, it must not add an asset to the bundle
/// for a screen seen once, and the whole animation is four transforms.
class ShareGestureDemo extends StatefulWidget {
  const ShareGestureDemo({super.key});

  @override
  State<ShareGestureDemo> createState() => _ShareGestureDemoState();
}

class _ShareGestureDemoState extends State<ShareGestureDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Reduced motion gets the *finished* frame — sheet up, target lit, saved —
    // which is the whole lesson, held still (PRD §8.3).
    if (AppMotion.isReduced(context)) {
      _controller.value = _restingFrame;
    } else {
      _controller.repeat();
    }
  }

  /// The point in the loop where everything the demo teaches is on screen at
  /// once. Used as the still frame under reduced motion.
  static const double _restingFrame = 0.72;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Animation: sharing a message from another app into Cya! using the '
          'system share sheet, saved in under a second.',
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 0.72,
        // The loop repaints ~60 times a second and nothing above it changes,
        // so it gets its own layer (PRD §9.1).
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => _DemoFrame(progress: _controller.value),
          ),
        ),
      ),
    );
  }
}

class _DemoFrame extends StatelessWidget {
  const _DemoFrame({required this.progress});

  final double progress;

  /// Eased 0→1 over [start]–[end], clamped outside.
  static double _phase(double t, double start, double end, {Curve? curve}) {
    final raw = ((t - start) / (end - start)).clamp(0.0, 1.0);
    return (curve ?? Curves.easeOutCubic).transform(raw);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final sheetIn = _phase(progress, 0.14, 0.34);
    final tap = _phase(progress, 0.36, 0.50, curve: Curves.easeOut);
    final saved = _phase(progress, 0.54, 0.66);
    final sheetOut = _phase(progress, 0.86, 1.0, curve: Curves.easeInCubic);
    final sheet = sheetIn * (1 - sheetOut);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        // --- the borrowed phone: another app, mid-conversation ---
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(color: colors.outlineVariant),
              boxShadow: cyaShadow(context, elevation: 1.6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _MockChatHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const _MockBubble(width: 0.52, mine: true),
                          const SizedBox(height: AppSpacing.sm),
                          const _MockBubble(width: 0.4, mine: false),
                          const SizedBox(height: AppSpacing.sm),
                          // The message the demo is about, highlighted as the
                          // thing being shared.
                          _SharedBubble(emphasis: 1 - sheetOut),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- dim behind the sheet, so the sheet reads as a system surface ---
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: sheet * 0.28,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
              ),
            ),
          ),
        ),

        // --- the share sheet, rising ---
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FractionalTranslation(
            translation: Offset(0, 1 - sheet),
            child: _ShareSheet(tap: tap),
          ),
        ),

        // --- "Saved · 0.1s", the promise the copy makes, kept on screen ---
        Positioned(
          top: -14,
          right: -6,
          child: Opacity(
            opacity: saved * (1 - sheetOut),
            child: Transform.scale(
              scale: 0.86 + 0.14 * saved,
              child: _SavedToast(),
            ),
          ),
        ),
      ],
    );
  }
}

class _MockChatHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cya = context.cyaColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      color: cya.surface2,
      child: Row(
        children: <Widget>[
          CircleAvatar(radius: 11, backgroundColor: cya.textSecondary.withValues(alpha: 0.28)),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 62,
            height: 8,
            decoration: BoxDecoration(
              color: cya.textSecondary.withValues(alpha: 0.32),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockBubble extends StatelessWidget {
  const _MockBubble({required this.width, required this.mine});

  final double width;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final cya = context.cyaColors;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: width,
        child: Container(
          height: 26,
          decoration: BoxDecoration(
            color: cya.surface2,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
    );
  }
}

/// The message being saved. Real words, not a grey bar: the user has to
/// recognise the situation as one of their own.
class _SharedBubble extends StatelessWidget {
  const _SharedBubble({required this.emphasis});

  final double emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.82,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: Color.lerp(
              context.cyaColors.surface2,
              colors.secondaryContainer,
              emphasis,
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            'can you send me the deck tonight?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet({required this.tap});

  /// 0→1 as the finger lands on the Cya! target.
  final double tap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        boxShadow: cyaShadow(context, elevation: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 34,
              height: 4,
              decoration: BoxDecoration(
                color: cya.textSecondary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Share via',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cya.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const _ShareTarget(),
              _CyaTarget(tap: tap),
              const _ShareTarget(),
              const _ShareTarget(),
            ],
          ),
        ],
      ),
    );
  }
}

/// One of the other apps in the sheet. Deliberately anonymous — naming real
/// competitors in a demo dates the screenshot and says nothing.
class _ShareTarget extends StatelessWidget {
  const _ShareTarget();

  @override
  Widget build(BuildContext context) {
    final cya = context.cyaColors;
    return Column(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cya.surface2,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Container(
          width: 26,
          height: 5,
          decoration: BoxDecoration(
            color: cya.textSecondary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}

/// The target the whole screen exists to point at.
class _CyaTarget extends StatelessWidget {
  const _CyaTarget({required this.tap});

  final double tap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A single pulse that grows and fades: a tap ripple, not a throb.
    final ripple = tap == 0 || tap == 1 ? 0.0 : tap;
    return Column(
      children: <Widget>[
        SizedBox(
          width: 52,
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: <Widget>[
              if (ripple > 0)
                Container(
                  width: 40 + 26 * ripple,
                  height: 40 + 26 * ripple,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(
                      alpha: 0.22 * (1 - ripple),
                    ),
                  ),
                ),
              Transform.scale(
                scale: 1 + 0.08 * (1 - (2 * tap - 1).abs()),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.brandGradient,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        spreadRadius: -2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    size: 22,
                    color: AppColors.onBrand,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Cya!',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SavedToast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: cyaShadow(context, elevation: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.check_circle_rounded, size: 16, color: cya.successInk),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            'Saved · 0.1s',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
