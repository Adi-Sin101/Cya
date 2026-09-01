import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/cya_haptics.dart';
import '../../../native/biometric_port.dart';
import '../../providers/identity_providers.dart';
import '../../providers/settings_providers.dart';
import '../lock/widgets/pin_pad.dart';

/// "Login", the local-only way (ADR-010): choose a PIN, confirm it, optionally
/// let a fingerprint stand in for typing it.
///
/// The last step of setup, and the only optional one. A lock is offered because
/// promises quote private conversations, and skipped without argument because a
/// trusted utility does not decide for you how private your own phone is.
///
/// The screen tells the truth about recovery. With no account there is no reset
/// link, and burying that until the day someone forgets would be the single
/// worst thing this flow could do.
class LockSetupScreen extends ConsumerStatefulWidget {
  const LockSetupScreen({super.key, this.isOnboarding = true});

  /// False when reached from Profile to change or add a lock later. The screen
  /// is identical; only where it came from and where it returns differ, which
  /// is not worth a second copy of a PIN keypad.
  final bool isOnboarding;

  @override
  ConsumerState<LockSetupScreen> createState() => _LockSetupScreenState();
}

enum _Stage { choose, confirm }

class _LockSetupScreenState extends ConsumerState<LockSetupScreen> {
  _Stage _stage = _Stage.choose;
  String _first = '';
  String _entry = '';
  bool _biometric = true;
  bool _mismatch = false;
  bool _saving = false;

  Future<void> _onDigit(String digit) async {
    if (_saving || _entry.length >= kPinLength) return;
    setState(() {
      _mismatch = false;
      _entry += digit;
    });
    if (_entry.length == kPinLength) await _onComplete();
  }

  void _onBackspace() {
    if (_saving || _entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _onComplete() async {
    if (_stage == _Stage.choose) {
      // Confirmation is not ceremony: a PIN mistyped once and stored is a
      // lockout with no way back, which for this product is data loss.
      setState(() {
        _first = _entry;
        _entry = '';
        _stage = _Stage.confirm;
      });
      CyaHaptics.selection(context);
      return;
    }

    if (_entry != _first) {
      CyaHaptics.warn(context);
      setState(() {
        _mismatch = true;
        _entry = '';
        _first = '';
        _stage = _Stage.choose;
      });
      return;
    }

    setState(() => _saving = true);
    final lock = ref.read(lockRepositoryProvider);
    await lock.setPin(_first);
    await lock.setBiometricEnabled(_biometric && await _biometricReady());
    // The lock is set, so this session is behind it — and has just proved it.
    ref.read(sessionLockProvider.notifier).unlock();
    await _finish();
  }

  Future<bool> _biometricReady() async {
    final availability = await ref.read(biometricAvailabilityProvider.future);
    return availability == BiometricAvailability.ready;
  }

  Future<void> _skip() async {
    CyaHaptics.tap(context);
    if (widget.isOnboarding) {
      ref.read(sessionLockProvider.notifier).unlock();
      await _finish();
      return;
    }
    _leave();
  }

  /// The end of setup. Marking onboarding complete here rather than at the last
  /// slide means an interrupted install resumes where it stopped instead of
  /// dropping someone into an app they were never shown.
  Future<void> _finish() async {
    if (widget.isOnboarding) {
      await ref.read(settingsControllerProvider).setOnboardingComplete();
    }
    if (!mounted) return;
    CyaHaptics.celebrate(context);
    _leave();
  }

  void _leave() {
    if (widget.isOnboarding) {
      context.go(RoutePaths.home);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    final availability = ref.watch(biometricAvailabilityProvider).valueOrNull;
    final canUseBiometric = availability == BiometricAvailability.ready;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => widget.isOnboarding
              ? context.go(RoutePaths.profileSetup)
              : _leave(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 30,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                widget.isOnboarding ? 'Lock your promises?' : 'Set a new PIN',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Your promises can hold private conversations. A PIN keeps '
                'them yours.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cya.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PinDots(entered: _entry.length, shake: _mismatch),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _prompt,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _mismatch ? cya.errorInk : cya.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PinPad(
                enabled: !_saving,
                onDigit: _onDigit,
                onBackspace: _onBackspace,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (canUseBiometric)
                _BiometricRow(
                  value: _biometric,
                  onChanged: (value) {
                    CyaHaptics.selection(context);
                    setState(() => _biometric = value);
                  },
                ),
              if (availability == BiometricAvailability.notEnrolled)
                _Note(
                  icon: Icons.fingerprint_rounded,
                  text:
                      'Add a fingerprint in your phone settings and Cya! will '
                      'offer it here.',
                ),
              const SizedBox(height: AppSpacing.lg),
              const _Note(
                icon: Icons.info_outline_rounded,
                text:
                    "There's no account, so there's no PIN reset. Forgetting "
                    'it means starting over.',
              ),
              const SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: _saving ? null : _skip,
                style: TextButton.styleFrom(
                  foregroundColor: cya.textSecondary,
                ),
                child: Text(
                  widget.isOnboarding ? 'Skip — no lock' : 'Cancel',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  String get _prompt => switch ((_mismatch, _stage, _saving)) {
    (_, _, true) => 'Saving…',
    (true, _, _) => "Those didn't match. Start again.",
    (_, _Stage.choose, _) => 'Choose a 4-digit PIN',
    (_, _Stage.confirm, _) => 'Type it once more',
  };
}

class _BiometricRow extends StatelessWidget {
  const _BiometricRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              size: 22,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Unlock with fingerprint',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Skip typing the PIN when your finger is enough.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.cyaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: cya.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cya.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
