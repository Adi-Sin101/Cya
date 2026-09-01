import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/cya_colors_extension.dart';
import '../../../core/utils/cya_haptics.dart';
import '../../../domain/enums/profile_avatar.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/motion/entrance.dart';
import '../../widgets/profile_avatar_view.dart';

/// "Registration", with no account behind it (ADR-010).
///
/// The product owner asked for proper registration and login *and* for
/// everything to stay local and private. Those are only in tension if identity
/// means a row in someone else's database. Here it means a name and a glyph in
/// the device's own SQLite file — the experience of setting up a profile, with
/// no email, no password, no server that can be down, and no token that can
/// expire between a person and their own promises.
///
/// So the screen says so, plainly, rather than leaving the absence of a sign-up
/// form to be read as an unfinished feature.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late final TextEditingController _name = TextEditingController(
    text: ref.read(displayNameProvider).valueOrNull ?? '',
  );
  late ProfileAvatar _avatar = ref.read(profileAvatarProvider);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    CyaHaptics.confirm(context);
    final settings = ref.read(settingsControllerProvider);
    await settings.setDisplayName(_name.text);
    await settings.setAvatar(_avatar);
    if (!mounted) return;
    context.go(RoutePaths.lockSetup);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(RoutePaths.onboarding)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                children: Entrance.staggered(<Widget>[
                  Text(
                    'What should I call you?',
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Only for the greeting on your home screen. There is no '
                    'account to create and nothing to sign in to.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: context.cyaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  Center(
                    child: ProfileAvatarView(
                      avatar: _avatar,
                      size: 112,
                      selected: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _AvatarChooser(
                    selected: _avatar,
                    onSelected: (avatar) {
                      CyaHaptics.selection(context);
                      setState(() => _avatar = avatar);
                    },
                  ),
                  const SizedBox(height: AppSpacing.section),
                  TextField(
                    controller: _name,
                    autofocus: false,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    style: theme.textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Your first name',
                      helperText: 'You can change this any time in Profile.',
                    ),
                    onSubmitted: (_) => _continue(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const _PrivacyCard(),
                  const SizedBox(height: AppSpacing.xxl),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.xl,
              ),
              child: SizedBox(
                width: double.infinity,
                // Never disabled on an empty name: a greeting is a courtesy,
                // and blocking someone from their own app over one is absurd.
                // Home already falls back to "You".
                child: FilledButton(
                  onPressed: _continue,
                  child: const Text('Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarChooser extends StatelessWidget {
  const _AvatarChooser({required this.selected, required this.onSelected});

  final ProfileAvatar selected;
  final ValueChanged<ProfileAvatar> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: <Widget>[
        for (final avatar in ProfileAvatar.values)
          Semantics(
            button: true,
            selected: avatar == selected,
            label: avatar.label,
            child: InkResponse(
              onTap: () => onSelected(avatar),
              radius: 34,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  ProfileAvatarView(
                    avatar: avatar,
                    size: 52,
                    selected: avatar == selected,
                  ),
                  // Selection is a ring *and* a check: never colour alone
                  // (PRD §8.4).
                  if (avatar == selected)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: _CheckBadge(),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CheckBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: colors.surface, width: 2),
      ),
      child: Icon(Icons.check_rounded, size: 11, color: colors.onPrimary),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cyaColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.shield_outlined,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'This profile never leaves your phone.',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'No email, no password, no cloud. Cya! has no server to send '
                  'it to — and no internet permission to try.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.cyaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
