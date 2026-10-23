import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../capture/capture_hub.dart';

/// A visible voice/text doorway. Opening it never starts the microphone.
class JournalCaptureCard extends ConsumerWidget {
  const JournalCaptureCard({super.key, this.showLibrary = false});
  final bool showLibrary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context), colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                color: colors.onSecondaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'A little space for your mind.',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth < 340
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: width,
                    child: FilledButton.icon(
                      onPressed: () =>
                          openMemoryCapture(context, ref, CaptureKind.voice),
                      icon: const Icon(Icons.mic_rounded),
                      label: const Text('Record voice'),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          openMemoryCapture(context, ref, CaptureKind.thought),
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('Write a thought'),
                    ),
                  ),
                ],
              );
            },
          ),
          if (showLibrary)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.go(RoutePaths.memories),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Open your memories'),
              ),
            ),
        ],
      ),
    );
  }
}
