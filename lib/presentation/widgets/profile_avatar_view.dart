import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/cya_colors_extension.dart';
import '../../domain/enums/profile_avatar.dart';

/// Draws a [ProfileAvatar] as a circular tonal tile.
///
/// The glyph and its tint live here rather than on the enum because `domain/`
/// imports nothing from Flutter (PRD §5.3) — and because which icon means
/// "sprout" is a design decision, not a data one.
class ProfileAvatarView extends StatelessWidget {
  const ProfileAvatarView({
    super.key,
    required this.avatar,
    this.size = 56,
    this.selected = false,
  });

  final ProfileAvatar avatar;
  final double size;

  /// Draws the selection ring. Paired with a check badge by the chooser, so
  /// selection is never carried by colour alone (PRD §8.4).
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.quick),
      curve: AppMotion.standard,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? colors.secondaryContainer : context.cyaColors.surface2,
        border: selected
            ? Border.all(color: colors.primary, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      alignment: Alignment.center,
      child: Icon(
        iconFor(avatar),
        size: size * 0.44,
        color: selected ? colors.onSecondaryContainer : colors.primary,
      ),
    );
  }

  /// Material's icon set has no beaver. The mascot's stand-in is a leaf-and-
  /// water mark that reads as the same idea — something patient that keeps
  /// things safe — rather than a literal animal that would look wrong beside
  /// the illustrated Cya.
  static IconData iconFor(ProfileAvatar avatar) => switch (avatar) {
    ProfileAvatar.beaver => Icons.eco_rounded,
    ProfileAvatar.sprout => Icons.local_florist_rounded,
    ProfileAvatar.moon => Icons.nightlight_round,
    ProfileAvatar.paperPlane => Icons.send_rounded,
    ProfileAvatar.coffee => Icons.local_cafe_rounded,
    ProfileAvatar.spark => Icons.auto_awesome_rounded,
  };
}
