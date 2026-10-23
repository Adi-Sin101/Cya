import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../data/db/cya_database.dart';
import '../../../domain/entities/memory.dart';
import '../../providers/memory_providers.dart';
import '../../widgets/local_feature_header.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key, required this.onOpen});
  final void Function(Memory) onOpen;
  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    List<MemoryCollectionRow> rows, [
    MemoryCollectionRow? current,
  ]) async {
    final text = TextEditingController(text: current?.title ?? '');
    var kind = current?.kind ?? 'topic';
    String? parent = current?.parentId, error;
    var busy = false;
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialog) => PopScope(
          canPop: !busy,
          child: AlertDialog(
            title: Text(
              current == null ? 'Create topic or project' : 'Edit organization',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: text,
                    maxLength: 160,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: kind,
                    items: [
                      for (final value in ['topic', 'project'])
                        DropdownMenuItem(value: value, child: Text(value)),
                    ],
                    onChanged: current != null || busy
                        ? null
                        : (value) => setDialog(() => kind = value!),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: parent ?? '',
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('No parent project'),
                      ),
                      for (final collection in rows.where(
                        (r) => r.kind == 'project' && r.id != current?.id,
                      ))
                        DropdownMenuItem(
                          value: collection.id,
                          child: Text(
                            collection.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: busy
                        ? null
                        : (value) => setDialog(
                            () => parent = value == '' ? null : value,
                          ),
                  ),
                  if (error != null) Text(error!),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: busy ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: busy
                    ? null
                    : () async {
                        setDialog(() {
                          busy = true;
                          error = null;
                        });
                        try {
                          await ref
                              .read(memoryConnectionsProvider)
                              .collection(
                                text.text,
                                kind,
                                ref.read(clockProvider)(),
                                id: current?.id,
                                parentId: parent,
                              );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        } on Object {
                          if (dialogContext.mounted) {
                            setDialog(() {
                              busy = false;
                              error =
                                  'Choose a title and a parent project without a cycle.';
                            });
                          }
                        }
                      },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
    await Navigator.of(context).push(route);
    await route.completed;
    text.dispose();
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    MemoryCollectionRow row,
  ) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this organization?'),
        content: const Text(
          'Thoughts, original audio and promises stay saved. Membership links are removed; child topics/projects become top level.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await ref.read(memoryConnectionsProvider).deleteCollection(row.id);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not remove this organization. Try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Topics and projects')),
    body: ref
        .watch(memoryCollectionsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
            child: Text('Could not read organization. Reopen to retry.'),
          ),
          data: (rows) {
            final byId = {for (final r in rows) r.id: r};
            final children = <String?, List<MemoryCollectionRow>>{};
            for (final r in rows) {
              children.putIfAbsent(r.parentId, () => []).add(r);
            }
            final ordered = <(MemoryCollectionRow, int)>[];
            void visit(String? parent, int depth) {
              if (depth > 32) return;
              for (final row in children[parent] ?? <MemoryCollectionRow>[]) {
                ordered.add((row, depth));
                visit(row.id, depth + 1);
              }
            }

            visit(null, 0);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const LocalFeatureHeader(
                        icon: Icons.account_tree_outlined,
                        title: 'Room for your ideas.',
                        description:
                            'Connect thoughts to topics and projects. Keep every source intact.',
                      ),
                      FilledButton.icon(
                        onPressed: () => _edit(context, ref, rows),
                        icon: const Icon(Icons.add),
                        label: const Text('Create topic or project'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ordered.isEmpty
                      ? const Center(
                          child: Text(
                            'No topics or projects yet. Capture still needs neither.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: ordered.length,
                          itemBuilder: (context, index) {
                            final (row, depth) = ordered[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                left: (depth > 5 ? 5 : depth) * 12.0,
                              ),
                              child: Card(
                                margin: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  leading: Icon(
                                    row.kind == 'project'
                                        ? Icons.work_outline
                                        : Icons.tag,
                                  ),
                                  title: Text(
                                    row.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  subtitle: Text(
                                    '${row.kind}${row.parentId == null ? '' : ' · ${byId[row.parentId]?.title ?? 'Parent project'}'}',
                                  ),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => CollectionMemoriesScreen(
                                        collection: row,
                                        onOpen: onOpen,
                                      ),
                                    ),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _edit(context, ref, rows, row);
                                      } else {
                                        _remove(context, ref, row);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit title or parent'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Remove organization'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
  );
}

class CollectionMemoriesScreen extends ConsumerWidget {
  const CollectionMemoriesScreen({
    super.key,
    required this.collection,
    required this.onOpen,
  });
  final MemoryCollectionRow collection;
  final void Function(Memory) onOpen;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text(collection.title)),
    body: ref
        .watch(collectionMemoriesProvider(collection.id))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              const Center(child: Text('Could not read linked versions.')),
          data: (items) => items.isEmpty
              ? const Center(
                  child: Text(
                    'Connect a thought from its menu to add it here.',
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(
                        item.displayText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Linked version ${item.revision}${item.archived ? ' · archived' : ''}',
                      ),
                      onTap: () => onOpen(item),
                    );
                  },
                ),
        ),
  );
}
