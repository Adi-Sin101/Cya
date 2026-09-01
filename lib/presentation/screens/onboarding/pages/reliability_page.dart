import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../core/utils/cya_haptics.dart';
import '../../../../native/device_reliability_port.dart';
import '../../../providers/reliability_providers.dart';
import '../widgets/onboarding_page_scaffold.dart';

/// Step 4 — the OEM settings that decide whether any of this works.
///
/// On a Poco this screen is worth more than the other three combined. MIUI and
/// HyperOS ship Autostart *off* for sideloaded apps, so `BOOT_COMPLETED` is
/// never delivered and a single reboot silently drops every pending alarm
/// (defect D-4). Samsung's battery care does the same job by a different name.
///
/// The tone is deliberately matter-of-fact: no red, no warning triangles, no
/// error colours. A reminder app that opens by telling the user their phone is
/// broken has picked a fight it does not need. It is a two-minute checklist,
/// and it says what it cannot do — Android exposes no API to flip any of these,
/// so the honest framing is "here is the door", not "let me fix that".
class ReliabilityPage extends ConsumerStatefulWidget {
  const ReliabilityPage({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  ConsumerState<ReliabilityPage> createState() => _ReliabilityPageState();
}

class _ReliabilityPageState extends ConsumerState<ReliabilityPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from a settings screen is the only moment any of these can
    // have changed — and the moment the user expects to see a tick.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(reliabilityChecklistProvider);
    }
  }

  Future<void> _open(ReliabilityStep step) async {
    CyaHaptics.tap(context);
    final port = ref.read(deviceReliabilityPortProvider);
    final opened = switch (step) {
      ReliabilityStep.autostart => await port.openAutostartSettings(),
      ReliabilityStep.battery => await port.openBatterySettings(),
      ReliabilityStep.exactAlarms => await port
          .openExactAlarmSettings()
          .then((_) => true),
      ReliabilityStep.notifications =>
        await ref.read(reminderPortProvider).ensureNotificationPermission(),
    };

    if (step == ReliabilityStep.autostart) {
      // Nothing reports autostart back, so the user's word is the only signal
      // there is. Recorded on the way out rather than behind a second tap:
      // making them confirm what they just did reads as distrust.
      await ref.read(confirmAutostartProvider)();
    }
    if (!mounted) return;
    if (!opened && step != ReliabilityStep.notifications) {
      _sayWhereToLook(step);
    }
    ref.invalidate(reliabilityChecklistProvider);
  }

  /// Several OEMs rename or remove these activities between versions. When the
  /// intent will not resolve, say where to go by hand — silence would look like
  /// a broken button.
  void _sayWhereToLook(ReliabilityStep step) {
    final device = ref
        .read(reliabilityChecklistProvider)
        .valueOrNull
        ?.device
        .oem;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_manualHint(step, device)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _manualHint(ReliabilityStep step, DeviceOem? oem) {
    if (step == ReliabilityStep.autostart) {
      return switch (oem) {
        DeviceOem.xiaomi =>
          "Couldn't open it. Settings → Apps → Manage apps → Cya! → Autostart.",
        DeviceOem.samsung =>
          "Couldn't open it. Settings → Battery → Background usage limits → "
              'Never sleeping apps.',
        DeviceOem.oppo || DeviceOem.vivo || DeviceOem.oneplus =>
          "Couldn't open it. Settings → Battery → App launch → Cya! → manage "
              'manually.',
        DeviceOem.huawei =>
          "Couldn't open it. Settings → Battery → App launch → Cya!.",
        _ => "Couldn't open that screen. It's in your phone's battery settings.",
      };
    }
    return "Couldn't open that screen. Look under Settings → Apps → Cya!.";
  }

  @override
  Widget build(BuildContext context) {
    final checklist =
        ref.watch(reliabilityChecklistProvider).valueOrNull ??
        ReliabilityChecklist.empty;

    return OnboardingPageScaffold(
      heroFlex: 0,
      hero: const SizedBox.shrink(),
      // The count is the device's, not ours: an OEM with an Autostart gate has
      // four rows, a stock device three. Naming a number the screen does not
      // show is the kind of small lie that makes the rest read as marketing.
      headline: checklist.device.needsAutostartStep
          ? 'Three switches your phone gets wrong.'
          : 'A few switches to check.',
      body:
          'Xiaomi, Samsung and a few others stop background apps by default — '
          'including alarm clocks. Two minutes here and your reminders arrive '
          'every time, even after a restart.',
      supporting: _Checklist(
        checklist: checklist,
        onOpen: _open,
      ),
      primaryLabel: checklist.isComplete
          ? 'All set — finish'
          : "I've done these — finish setup",
      onPrimary: widget.onFinish,
      secondaryLabel: checklist.isComplete ? null : 'Remind me later',
      onSecondary: widget.onFinish,
    );
  }
}

class _Checklist extends StatelessWidget {
  const _Checklist({required this.checklist, required this.onOpen});

  final ReliabilityChecklist checklist;
  final void Function(ReliabilityStep) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DeviceChip(label: checklist.device.label),
        const SizedBox(height: AppSpacing.lg),
        for (final check in checklist.checks) ...<Widget>[
          _StepCard(check: check, onOpen: () => onOpen(check.step)),
          const SizedBox(height: AppSpacing.md),
        ],
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: <Widget>[
            Text(
              '${checklist.satisfiedCount} of ${checklist.checks.length} done',
              style: theme.textTheme.labelSmall?.copyWith(
                color: cya.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: checklist.progress),
                  duration: AppMotion.of(context, AppMotion.gentle),
                  curve: AppMotion.standard,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 4,
                    backgroundColor: cya.surface2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.info_outline_rounded, size: 16, color: cya.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                "Cya! can't change these for you — Android only lets you do it "
                'yourself.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cya.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeviceChip extends StatelessWidget {
  const _DeviceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm - 2,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.smartphone_rounded,
              size: 14,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: AppSpacing.xs + 2),
            // Flexible, not fixed: the label is whatever the OEM calls itself,
            // and a long one ("Xiaomi · HyperOS" at a large text scale) must
            // shorten rather than run off the chip.
            Flexible(
              child: Text(
                'Detected: $label',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.check, required this.onOpen});

  final ReliabilityCheck check;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    final done = check.satisfied;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: cyaShadow(context),
      ),
      child: Row(
        children: <Widget>[
          // A completed row is quietened, never struck through or reddened:
          // the eye should land on what is left to do (PRD §8.4 — state is
          // never colour alone, so the chip beside it says the word too).
          Opacity(
            opacity: done ? 0.55 : 1,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                _icon(check.step),
                size: 22,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_title(check.step), style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  _detail(check.step),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cya.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (done)
            _DoneChip()
          else
            OutlinedButton(
              onPressed: onOpen,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                foregroundColor: theme.colorScheme.primary,
                shape: const StadiumBorder(),
              ),
              child: const Text('Open'),
            ),
        ],
      ),
    );
  }

  static IconData _icon(ReliabilityStep step) => switch (step) {
    ReliabilityStep.autostart => Icons.restart_alt_rounded,
    ReliabilityStep.battery => Icons.battery_charging_full_rounded,
    ReliabilityStep.exactAlarms => Icons.alarm_rounded,
    ReliabilityStep.notifications => Icons.notifications_active_rounded,
  };

  static String _title(ReliabilityStep step) => switch (step) {
    ReliabilityStep.autostart => 'Autostart',
    ReliabilityStep.battery => 'Battery',
    ReliabilityStep.exactAlarms => 'Exact alarms',
    ReliabilityStep.notifications => 'Notifications',
  };

  static String _detail(ReliabilityStep step) => switch (step) {
    ReliabilityStep.autostart =>
      'Let Cya! wake up after your phone restarts.',
    ReliabilityStep.battery => "Don't restrict Cya! in the background.",
    ReliabilityStep.exactAlarms =>
      'Fire at the minute you chose, not whenever.',
    ReliabilityStep.notifications => 'Let the reminder actually appear.',
  };
}

class _DoneChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm - 2,
      ),
      decoration: BoxDecoration(
        color: cya.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.check_rounded, size: 15, color: cya.successInk),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Done',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cya.successInk,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
