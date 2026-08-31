import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../domain/projections/week_projection.dart';

/// The current calendar day, which changes on its own at midnight.
///
/// "Today's promises" reads a day boundary computed from `clockProvider()`.
/// That is a plain function, so nothing invalidates it — an app left open
/// across midnight kept showing yesterday until something else happened to
/// rebuild it. A promise manager that is wrong about what day it is at 00:01
/// is wrong about the only thing it does.
///
/// This provider holds the day and schedules exactly one timer, for the next
/// midnight. Not a periodic tick: a one-minute poll to answer a question that
/// changes once a day would keep the isolate awake ~1,440 times more often
/// than it needs to be (PRD §9.4).
///
/// It also re-checks on resume, because a `Timer` does not fire while the
/// process is frozen in the background — coming back at 09:00 to a rollover
/// that was scheduled for 00:00 has to be caught, not waited for.
final todayProvider = NotifierProvider<TodayNotifier, DateTime>(
  TodayNotifier.new,
);

class TodayNotifier extends Notifier<DateTime> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  DateTime build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      _timer?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });
    final now = ref.watch(clockProvider)();
    _scheduleRollover(now);
    return WeekProjection.startOfDay(now);
  }

  @override
  // The base class calls this parameter `state`, which is also the Notifier's
  // own property. Shadowing it inside a Notifier is a trap worth renaming past.
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed) _refresh();
  }

  void _refresh() {
    final now = ref.read(clockProvider)();
    final today = WeekProjection.startOfDay(now);
    _scheduleRollover(now);
    if (today != state) state = today;
  }

  void _scheduleRollover(DateTime now) {
    _timer?.cancel();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    // A second past midnight, so the timer can never fire a hair early and
    // compute the day it just left.
    final untilMidnight =
        nextMidnight.difference(now) + const Duration(seconds: 1);
    _timer = Timer(
      untilMidnight.isNegative ? Duration.zero : untilMidnight,
      _refresh,
    );
  }
}
