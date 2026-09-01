import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/cya_colors_extension.dart';
import '../../../../core/utils/cya_haptics.dart';
import '../../../../domain/entities/intention.dart';

/// Write the reply now, send it in one tap when you get there (ADR-015).
///
/// The honest version of "scheduled replies". Android has no public API to send
/// a message in someone else's app, so Cya! does the part that actually takes
/// the effort — composing while the context is in front of you — and hands the
/// finished text to the conversation. The send stays the user's.
///
/// Shown only for promises that came from a real app, because a draft with
/// nowhere to go is a notes field, and the capture sheet already is one.
class ReplyDraftCard extends ConsumerStatefulWidget {
  const ReplyDraftCard({super.key, required this.promise});

  final Intention promise;

  /// Whether this promise can be replied to at all.
  static bool suits(Intention promise) =>
      promise.sourcePackage != null || promise.deepLink != null;

  @override
  ConsumerState<ReplyDraftCard> createState() => _ReplyDraftCardState();
}

class _ReplyDraftCardState extends ConsumerState<ReplyDraftCard> {
  final TextEditingController _draft = TextEditingController();
  bool _open = false;

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _handOff() async {
    final text = _draft.text.trim();
    if (text.isEmpty) return;
    CyaHaptics.confirm(context);
    final opened = await ref
        .read(reminderPortProvider)
        .openDraft(
          draft: text,
          packageName: widget.promise.sourcePackage,
          link: widget.promise.deepLink,
        );
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't open ${widget.promise.sourceApp}. Your draft is still "
            'here.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cya = context.cyaColors;

    return Container(
      decoration: BoxDecoration(
        color: cya.surface2,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Collapsed by default: most promises are resolved by going to the
          // app, not by writing here, and an always-open text field on a
          // resurface screen competes with "Mark as Done".
          InkWell(
            onTap: () {
              CyaHaptics.tap(context);
              setState(() => _open = !_open);
            },
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.edit_note_rounded,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Write the reply now',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: AppMotion.of(context, AppMotion.quick),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: cya.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: AppMotion.of(context, AppMotion.gentle),
            curve: AppMotion.standard,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TextField(
                          controller: _draft,
                          minLines: 3,
                          maxLines: 6,
                          textCapitalization: TextCapitalization.sentences,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Hey — sorry for the delay, just seeing this…',
                            fillColor: theme.colorScheme.surface,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton.icon(
                          onPressed: _draft.text.trim().isEmpty
                              ? null
                              : _handOff,
                          icon: const Icon(Icons.send_rounded, size: 20),
                          label: Text('Open ${widget.promise.sourceApp}'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "Cya! opens the conversation with this ready. It "
                          'never sends anything for you.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cya.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
