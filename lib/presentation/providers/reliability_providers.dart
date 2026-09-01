import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/dao/preference_dao.dart';
import '../../native/device_reliability_port.dart';

/// The onboarding reliability checklist (iteration 9, defect D-4).
///
/// This is the screen that decides whether the product works at all on the two
/// devices Phase 1 is measured on. Android's own guarantees stop at the OEM: a
/// sideloaded app on HyperOS has Autostart off by default, so `BOOT_COMPLETED`
/// never arrives and a reboot silently drops every pending alarm.

/// One row of the checklist.
enum ReliabilityStep {
  /// Survive a reboot. Unreadable — the user confirms it (see [keyForStep]).
  autostart,

  /// Run when the screen is off.
  battery,

  /// Fire at the chosen minute rather than in an OS-chosen window.
  exactAlarms,

  /// Be allowed to post the reminder at all.
  notifications,
}

class ReliabilityCheck {
  const ReliabilityCheck(this.step, {required this.satisfied});

  final ReliabilityStep step;

  /// For [ReliabilityStep.autostart] this is what the user told us, not what
  /// the system reported — nothing else is available.
  final bool satisfied;
}

class ReliabilityChecklist {
  const ReliabilityChecklist(this.device, this.checks);

  static const ReliabilityChecklist empty = ReliabilityChecklist(
    DeviceReliability.unknown,
    <ReliabilityCheck>[],
  );

  final DeviceReliability device;
  final List<ReliabilityCheck> checks;

  int get satisfiedCount => checks.where((c) => c.satisfied).length;

  bool get isComplete => checks.every((c) => c.satisfied);

  double get progress =>
      checks.isEmpty ? 0 : satisfiedCount / checks.length;
}

final deviceReliabilityPortProvider = Provider<DeviceReliabilityPort>(
  (ref) => const DeviceReliabilityPort(),
);

/// The live checklist.
///
/// Invalidate it when the user comes back from a settings screen — that is the
/// only moment any of these values can have changed.
final reliabilityChecklistProvider = FutureProvider<ReliabilityChecklist>((
  ref,
) async {
  final device = await ref.watch(deviceReliabilityPortProvider).read();
  final confirmed =
      await ref
          .watch(preferenceDaoProvider)
          .read(PreferenceDao.keyAutostartConfirmed) ==
      'true';

  return ReliabilityChecklist(device, <ReliabilityCheck>[
    // Only shown where it exists: a checklist row a stock device can never
    // tick would read as a permanent failure.
    if (device.needsAutostartStep)
      ReliabilityCheck(ReliabilityStep.autostart, satisfied: confirmed),
    ReliabilityCheck(
      ReliabilityStep.battery,
      satisfied: device.batteryUnrestricted,
    ),
    ReliabilityCheck(
      ReliabilityStep.exactAlarms,
      satisfied: device.exactAlarms,
    ),
    ReliabilityCheck(
      ReliabilityStep.notifications,
      satisfied: device.notifications,
    ),
  ]);
});

/// Records that the user says they enabled Autostart.
final confirmAutostartProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await ref
        .read(preferenceDaoProvider)
        .write(PreferenceDao.keyAutostartConfirmed, 'true');
    ref.invalidate(reliabilityChecklistProvider);
  };
});
