import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/memory.dart';
import '../../providers/intention_providers.dart';
import '../../providers/memory_providers.dart';

Future<bool?> showConnectionPicker(BuildContext context, Memory source) =>
    showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ConnectionPicker(source: source),
    );

class _ConnectionPicker extends ConsumerStatefulWidget {
  const _ConnectionPicker({required this.source});
  final Memory source;
  @override
  ConsumerState<_ConnectionPicker> createState() => _PickerState();
}

class _PickerState extends ConsumerState<_ConnectionPicker> {
  String _mode = 'thought', _query = '';
  String? _error;
  bool _busy = false;
  Future<void> _save(Future<void> Function() work) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await work();
      if (mounted) Navigator.pop(context, true);
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'Could not save this connection. The source is unchanged. Try another version or destination.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _thought(Memory target) async {
    final history = await ref
        .read(memoryRepositoryProvider)
        .history(target.id)
        .first;
    if (!mounted) return;
    final choices = history
        .where((r) => r.revisionId != widget.source.revisionId)
        .toList();
    if (choices.isEmpty) {
      setState(
        () => _error = 'Choose a different thought or an earlier version.',
      );
      return;
    }
    var selected = choices.first;
    var kind = 'related';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: const Text('Create your own connection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                target.displayText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: selected.revisionId,
                items: [
                  for (final revision in choices)
                    DropdownMenuItem(
                      value: revision.revisionId,
                      child: Text('Version ${revision.revision}'),
                    ),
                ],
                onChanged: (id) => setDialog(
                  () =>
                      selected = choices.firstWhere((r) => r.revisionId == id),
                ),
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: kind,
                items: [
                  for (final value in [
                    'related',
                    'supports',
                    'contradicts',
                    'supersedes',
                  ])
                    DropdownMenuItem(value: value, child: Text(value)),
                ],
                onChanged: (value) => setDialog(() => kind = value!),
              ),
              const Text(
                'The direction runs from your source version to this chosen version. Both originals stay separate.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    await _save(() async {
      await ref
          .read(memoryConnectionsProvider)
          .link(
            widget.source.revisionId,
            selected.revisionId,
            kind,
            ref.read(clockProvider)(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();
    final content = switch (_mode) {
      'thought' =>
        ref
            .watch(memoriesProvider((query: _query, archived: false)))
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  const Center(child: Text('Could not read thoughts.')),
              data: (items) => ListView(
                children: [
                  for (final memory in items.take(100))
                    ListTile(
                      title: Text(
                        memory.displayText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Choose version · ${memory.isAudio ? 'Original audio' : 'Text'}',
                      ),
                      onTap: _busy ? null : () => _thought(memory),
                    ),
                  if (items.isEmpty)
                    const ListTile(title: Text('No matching thoughts.')),
                ],
              ),
            ),
      'promise' =>
        ref
            .watch(allIntentionsProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  const Center(child: Text('Could not read promises.')),
              data: (items) {
                final matches = items
                    .where((i) => i.rawContent.toLowerCase().contains(query))
                    .take(100)
                    .toList();
                return ListView(
                  children: [
                    for (final promise in matches)
                      ListTile(
                        title: Text(
                          promise.rawContent,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: const Text(
                          'Existing promise · no new task or reminder',
                        ),
                        onTap: _busy
                            ? null
                            : () => _save(() async {
                                await ref
                                    .read(memoryConnectionsProvider)
                                    .assign(
                                      widget.source.revisionId,
                                      ref.read(clockProvider)(),
                                      intentionId: promise.id,
                                    );
                              }),
                      ),
                    if (matches.isEmpty)
                      const ListTile(
                        title: Text(
                          'No matching active promises. Create one with the existing promise capture first.',
                        ),
                      ),
                  ],
                );
              },
            ),
      _ =>
        ref
            .watch(memoryCollectionsProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  const Center(child: Text('Could not read topics/projects.')),
              data: (items) {
                final matches = items
                    .where((c) => c.title.toLowerCase().contains(query))
                    .take(100)
                    .toList();
                return ListView(
                  children: [
                    for (final collection in matches)
                      ListTile(
                        title: Text(collection.title),
                        subtitle: Text(collection.kind),
                        onTap: _busy
                            ? null
                            : () => _save(() async {
                                await ref
                                    .read(memoryConnectionsProvider)
                                    .assign(
                                      widget.source.revisionId,
                                      ref.read(clockProvider)(),
                                      collectionId: collection.id,
                                    );
                              }),
                      ),
                    if (matches.isEmpty)
                      const ListTile(
                        title: Text(
                          'No matching topics/projects. Create one from Topics and projects.',
                        ),
                      ),
                  ],
                );
              },
            ),
    };
    return PopScope(
      canPop: !_busy,
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .8,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Connect version ${widget.source.revision}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                  'Choose an explicit relationship. Suggestions never create these automatically. Search to narrow the first100 results.',
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final mode in ['thought', 'promise', 'collection'])
                      ChoiceChip(
                        label: Text(
                          mode == 'collection' ? 'Topic / project' : mode,
                        ),
                        selected: _mode == mode,
                        onSelected: _busy
                            ? null
                            : (_) => setState(() => _mode = mode),
                      ),
                  ],
                ),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    labelText: 'Find a destination',
                  ),
                ),
                if (_error != null) Text(_error!),
                if (_busy) const LinearProgressIndicator(),
                Expanded(child: content),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
