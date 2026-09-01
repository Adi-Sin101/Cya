import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/cya_haptics.dart';
import '../../../domain/entities/lock_settings.dart';
import '../../providers/identity_providers.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/profile_avatar_view.dart';
import 'widgets/pin_pad.dart';

/// The unlock screen (ADR-010).
///
/// It greets before it challenges — the avatar and the name first, the dots
/// second. A memory product's lock screen is crossed several times a week by
/// exactly one person, and making that person feel checked at a door every time
/// is how a companion turns into a bureaucracy.
///
/// There is no "forgot PIN" link. With no account there is no recovery, and a
/// link that led to an apology would be worse than its absence — the setup
/// screen said so plainly, and this screen does not pretend otherwise.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _entry = '';
  bool _checking = false;
  bool _rejected = false;
  String? _message;
  Duration _cooldown = Duration.zero;
  Timer? _cooldownTicker;
  bool _promptedBiometric = false;

  @override
  void initState() {
    super.initState();
    // Offer the fingerprint immediately rather than making the user reach for
    // it: if it is on, it is the way in, and the keypad is the fallback.
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerBiometric());
  }

  @override
  void dispose() {
    _cooldownTicker?.cancel();
    super.dispose();
  }

  Future<void> _offerBiometric() async {
    if (_promptedBiometric || !mounted) return;
    final settings = await ref.read(lockRepositoryProvider).read();
    if (!settings.biometricEnabled || !mounted) return;
    _promptedBiometric = true;

    final ok = await ref
        .read(biometricPortProvider)
        .authenticate(
          title: 'Unlock Cya!',
          subtitle: 'Your promises are waiting.',
          negativeLabel: 'Use PIN',
        );
    if (ok && mounted) _unlock();
  }

  void _unlock() {
    CyaHaptics.confirm(context);
    ref.read(sessionLockProvider.notifier).unlock();
  }

  Future<void> _onDigit(String digit) async {
    if (_checking || _cooldown > Duration.zero) return;
    if (_entry.length >= kPinLength) return;
    setState(() {
      _rejected = false;
      _message = null;
      _entry += digit;
    });
    if (_entry.length == kPinLength) await _submit();
  }

  void _onBackspace() {
    if (_checking || _entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _checking = true);
    final verdict = await ref.read(lockRepositoryProvider).verify(_entry);
    if (!mounted) return;

    switch (verdict) {
      case PinAccepted():
        setState(() => _checking = false);
        _unlock();
      case PinRejected(:final attemptsRemaining):
        CyaHaptics.warn(context);
        setState(() {
          _checking = false;
          _rejected = true;
          _entry = '';
          _message = attemptsRemaining <= 2
              ? 'Not quite. $attemptsRemaining ${attemptsRemaining == 1 ? 'try' : 'tries'} before a short wait.'
              : 'Not quite. Try again.';
        });
      case PinCooldown(:final remaining):
        CyaHaptics.warn(context);
        setState(() {
          _checking = false;
          _rejected = true;
          _entry = '';
        });
        _startCooldown(remaining);
    }
  }

  /// Counts the wait down out loud. A disabled keypad with no explanation reads
  /// as a broken app; a number that moves reads as a rule.
  void _startCooldown(Duration remaining) {
    _cooldownTicker?.cancel();
    setState(() => _cooldown = remaining);
    _cooldownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      final next = _cooldown - const Duration(seconds: 1);
      setState(() => _cooldown = next.isNegative ? Duration.zero : next);
      if (_cooldown == Duration.zero) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;
    final name = ref.watch(displayNameProvider).valueOrNull;
    final avatar = ref.watch(profileAvatarProvider);
    final biometricOn =
        ref.watch(lockSettingsProvider).valueOrNull?.biometricEnabled ?? false;
    final waiting = _cooldown > Duration.zero;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ProfileAvatarView(avatar: avatar, size: 72, selected: true),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Welcome back',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cya.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  name == null || name.trim().isEmpty ? 'Cya!' : name,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.section),
                PinDots(entered: _entry.length, shake: _rejected),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 20,
                  child: Text(
                    waiting
                        ? 'Too many tries. Again in ${_cooldown.inSeconds}s.'
                        : _message ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _rejected || waiting
                          ? cya.errorInk
                          : cya.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PinPad(
                  enabled: !_checking && !waiting,
                  onDigit: _onDigit,
                  onBackspace: _onBackspace,
                  onBiometric: biometricOn
                      ? () {
                          _promptedBiometric = false;
                          _offerBiometric();
                        }
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
