import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/audio/pcm_wave.dart';
import '../../../domain/entities/memory.dart';
import '../../providers/memory_providers.dart';

class MemoryJournalTile extends ConsumerWidget {
  const MemoryJournalTile({
    super.key,
    required this.memory,
    required this.onOpen,
    required this.onPlay,
    required this.onAction,
  });
  final Memory memory;
  final VoidCallback onOpen, onPlay;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context), colors = theme.colorScheme;
    final audio = memory.isAudio
        ? ref.watch(audioForMemoryProvider(memory.id)).valueOrNull
        : null;
    final local = memory.capturedAt.toLocal();
    final date = MaterialLocalizations.of(context).formatMediumDate(local);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(local));
    final seconds = (audio?.durationMillis ?? 0) ~/ 1000;
    final duration = audio == null
        ? 'Original audio'
        : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')} · Original audio';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: memory.isAudio
            ? colors.secondaryContainer.withValues(alpha: .45)
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      memory.isAudio ? Icons.mic_rounded : Icons.notes_rounded,
                      color: colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        memory.isAudio ? 'Voice journal' : 'Thought',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Memory actions',
                      onSelected: onAction,
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'history',
                          child: Text('History'),
                        ),
                        const PopupMenuItem(
                          value: 'related',
                          child: Text('Related thoughts'),
                        ),
                        const PopupMenuItem(
                          value: 'connect',
                          child: Text('Connect explicitly'),
                        ),
                        const PopupMenuItem(
                          value: 'branch',
                          child: Text('Explore a branch'),
                        ),
                        PopupMenuItem(
                          value: 'archive',
                          child: Text(memory.archived ? 'Restore' : 'Archive'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete permanently'),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  memory.displayText,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                if (memory.isAudio) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: onPlay,
                        tooltip: 'Play original audio',
                        icon: const Icon(Icons.play_arrow_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(duration, style: theme.textTheme.bodySmall),
                      ),
                    ],
                  ),
                  if (memory.matchingSegment != null)
                    Text(
                      'Audio match near ${memory.matchingSegment! * PcmWave.segmentSeconds}s',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
                const SizedBox(height: 12),
                Text(
                  '$date / $time · Version ${memory.revision}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () => onAction('related'),
                      icon: const Icon(Icons.hub_outlined, size: 18),
                      label: const Text('Connections'),
                    ),
                    TextButton.icon(
                      onPressed: () => onAction('branch'),
                      icon: const Icon(Icons.call_split_rounded, size: 18),
                      label: const Text('Branch'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
