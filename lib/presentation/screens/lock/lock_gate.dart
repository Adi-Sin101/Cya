import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_motion.dart';
import '../../providers/identity_providers.dart';
import 'lock_screen.dart';

/// Draws the unlock screen *over* the app rather than routing to it.
///
/// The difference matters for the one flow this product is built around: a
/// reminder notification deep-links to `cya://promise/<id>`, the router resolves
/// that promise behind the gate, and entering the PIN reveals it — instead of
/// landing on a lock screen that has forgotten where the user was going and
/// dropping them on Home (PRD §3.4).
///
/// Installed in `MaterialApp.builder`, so it also covers dialogs, sheets and
/// anything else the navigator has pushed.
class LockGate extends ConsumerWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = ref.watch(lockGateProvider);
    return Stack(
      children: <Widget>[
        // A screen reader behind a lock screen would happily read out every
        // promise on it, so the app is excluded from semantics, not just from
        // hit tests.
        ExcludeSemantics(excluding: locked, child: child),
        // Unlocking fades the app in rather than sliding a route away —
        // nothing "left"; the app was there the whole time.
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !locked,
            child: AnimatedOpacity(
              opacity: locked ? 1 : 0,
              duration: AppMotion.of(context, AppMotion.gentle),
              curve: AppMotion.standard,
              child: locked
                  ? Material(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: const LockScreen(),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
