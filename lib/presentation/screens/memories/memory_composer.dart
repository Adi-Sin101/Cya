import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../domain/entities/memory.dart';
import '../../providers/memory_providers.dart';

Future<bool> showMemoryComposer(
  BuildContext context,
  WidgetRef ref, {
  Memory? memory,
}) async {
  final text = TextEditingController(text: memory?.text ?? '');
  var saving = false;
  String? error;
  final original = memory?.text ?? '';
  final route = DialogRoute<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        Future<void> close() async {
          if (saving) return;
          if (text.text != original) {
            final discard = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Leave this draft?'),
                content: const Text(
                  'Your unsaved changes will be discarded. Saved originals stay unchanged.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Keep writing'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Discard draft'),
                  ),
                ],
              ),
            );
            if (discard != true) return;
          }
          if (dialogContext.mounted) Navigator.pop(dialogContext, false);
        }

        Future<void> save() async {
          if (text.text.trim().isEmpty && memory?.isAudio != true) {
            setDialogState(() => error = 'Write a thought before saving.');
            return;
          }
          setDialogState(() {
            saving = true;
            error = null;
          });
          try {
            final repo = ref.read(memoryRepositoryProvider);
            final now = ref.read(clockProvider)();
            if (memory == null) {
              await repo.captureText(text.text, now);
            } else {
              await repo.edit(
                memory.id,
                text.text,
                now,
                expectedRevision: memory.revision,
              );
            }
            if (dialogContext.mounted) Navigator.pop(dialogContext, true);
          } on Object {
            if (dialogContext.mounted) {
              setDialogState(() {
                saving = false;
                error =
                    'Could not save. Keep this text and try again. If it changed elsewhere, reopen it.';
              });
            }
          }
        }

        final theme = Theme.of(context);
        return PopScope(
          canPop: !saving && text.text == original,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && !saving) close();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: saving ? null : close,
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Close thought',
              ),
              title: Text(
                memory == null ? 'Save a thought' : 'Update this thought',
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            memory?.isAudio == true
                                ? Icons.mic_rounded
                                : Icons.edit_note_rounded,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            memory?.isAudio == true
                                ? 'Words alongside your voice.'
                                : 'Give your thought some space.',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            memory != null
                                ? 'Your original and earlier versions are preserved.'
                                : 'No title. No tags. Just what is on your mind.',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: text,
                            autofocus: true,
                            minLines: 8,
                            maxLines: null,
                            maxLength: 100000,
                            enabled: !saving,
                            onChanged: (_) => setDialogState(() {}),
                            decoration: InputDecoration(
                              hintText: 'What is on your mind?',
                              counterText: '',
                              errorText: error,
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: saving ? null : close,
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: saving ? null : save,
                            icon: const Icon(Icons.check_rounded),
                            label: Text(saving ? 'Saving...' : 'Save thought'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  final saved = await Navigator.of(context, rootNavigator: true).push(route);
  await route.completed;
  text.dispose();
  return saved == true;
}

Future<void> showSavedMemoryNotice(BuildContext context, WidgetRef ref) async {
  // Called only after the original source, event and durable job have committed.
  // Covers Home, global capture and Focus, without loading a model on open.
  ref.read(semanticIndexProvider).resume();
  String? priority;
  try {
    priority = await ref.read(preferenceDaoProvider).read(focusPriorityKey);
  } on Object {
    // Save has already committed; a focus-read error must not undo success.
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        priority == null || priority.isEmpty
            ? 'Thought saved.'
            : 'Thought saved. You chose “$priority”. Return to it when you’re ready.',
      ),
      showCloseIcon: true,
    ),
  );
}
