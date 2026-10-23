import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/cya_haptics.dart';
import '../memories/memory_composer.dart';
import '../memories/voice_capture_sheet.dart';
import 'capture_sheet.dart';

enum CaptureKind { voice, thought, promise }

/// The app capture menu; native share/tile/widget still save directly.
Future<void> showCaptureHub(BuildContext context, WidgetRef ref) async {
  final kind = await showModalBottomSheet<CaptureKind>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Keep this moment',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('A thought, your voice, or something for later.'),
            const SizedBox(height: 24),
            for (final item in const [
              (
                CaptureKind.voice,
                Icons.mic_rounded,
                'Record voice',
                'Keep the original audio',
              ),
              (
                CaptureKind.thought,
                Icons.edit_note_rounded,
                'Write a thought',
                'No title or tags needed',
              ),
              (
                CaptureKind.promise,
                Icons.bookmark_add_outlined,
                'Capture a promise',
                'Choose when to be reminded',
              ),
            ]) ...[
              CaptureChoice(
                icon: item.$2,
                title: item.$3,
                subtitle: item.$4,
                onTap: () => Navigator.pop(context, item.$1),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    ),
  );
  if (kind != null && context.mounted) {
    await openMemoryCapture(context, ref, kind);
  }
}

Future<void> openMemoryCapture(
  BuildContext context,
  WidgetRef ref,
  CaptureKind kind,
) async {
  CyaHaptics.tap(context);
  if (kind == CaptureKind.promise) {
    showCaptureSheet(context);
    return;
  }
  final saved = kind == CaptureKind.voice
      ? await showVoiceCapture(context) == true
      : await showMemoryComposer(context, ref);
  if (saved && context.mounted) await showSavedMemoryNotice(context, ref);
}

class CaptureChoice extends StatelessWidget {
  const CaptureChoice({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: colors.onSecondaryContainer, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
