import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../domain/entities/routine.dart';
import '../../providers/routine_providers.dart';
import 'routine_editor.dart';

class RoutinesScreen extends ConsumerStatefulWidget {
  const RoutinesScreen({super.key});
  @override
  ConsumerState<RoutinesScreen> createState() => _RoutinesState();
}

class _RoutinesState extends ConsumerState<RoutinesScreen> {
  bool _removed = false;
  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not change this routine. Reopen the list and try again.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _action(
    Routine routine,
    String action,
    List<Routine> rows,
  ) async {
    final repo = ref.read(routineRepositoryProvider),
        at = ref.read(clockProvider)();
    if (action == 'edit') {
      await editRoutine(context, ref, routine);
      return;
    }
    if (action == 'history') {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .75,
            child: Consumer(
              builder: (context, ref, _) => ref
                  .watch(routineVersionsProvider(routine.id))
                  .when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Center(
                      child: Text('Could not read routine history.'),
                    ),
                    data: (versions) => ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Text(
                          'Routine versions',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Text(
                          'Past plans keep the version you selected. Use the day picker in Your day to inspect recorded occurrences.',
                        ),
                        for (final version in versions)
                          ListTile(
                            title: Text(
                              'Version ${version.revision} · ${version.title}',
                            ),
                            subtitle: Text(
                              '${version.createdAt.toLocal()}\n${preferredWindow(version.preferredStart, version.preferredEnd)}\n${routineSteps(version.steps).join('\n')}${version.fallback == null ? '' : '\nLighter fallback: ${version.fallback}'}',
                            ),
                          ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      );
      return;
    }
    if (action == 'remove') {
      final yes = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove this routine?'),
          content: const Text(
            'It leaves the available routine list. All versions, past selections and recorded outcomes remain in history. You can restore it later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep routine'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove routine'),
            ),
          ],
        ),
      );
      if (yes == true) await _run(() => repo.remove(routine.id, at));
      return;
    }
    if (action == 'restore') {
      await _run(() => repo.remove(routine.id, at, restore: true));
      return;
    }
    if (action == 'pause') {
      await _run(() => repo.pause(routine.id, !routine.paused, at));
      return;
    }
    final ids = rows.where((r) => !r.deleted).map((r) => r.id).toList(),
        index = rows
            .where((r) => !r.deleted)
            .map((r) => r.id)
            .toList()
            .indexOf(routine.id);
    final other = index + (action == 'up' ? -1 : 1);
    if (index < 0 || other < 0 || other >= ids.length) return;
    final value = ids[index];
    ids[index] = ids[other];
    ids[other] = value;
    await _run(() => repo.reorder(ids, at));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Your routines'),
      actions: [
        IconButton(
          onPressed: () => setState(() => _removed = !_removed),
          icon: Icon(_removed ? Icons.inventory : Icons.inventory_2_outlined),
          tooltip: _removed ? 'Hide removed routines' : 'Show removed routines',
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => editRoutine(context, ref),
      icon: const Icon(Icons.add),
      label: const Text('Create routine'),
    ),
    body: ref
        .watch(routinesProvider(_removed))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
            child: Text('Could not read routines. Reopen to retry.'),
          ),
          data: (rows) => rows.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('A little rhythm starts with one routine.'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final routine = rows[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Icon(
                              routine.paused
                                  ? Icons.pause_rounded
                                  : Icons.spa_outlined,
                            ),
                          ),
                          title: Text(
                            routine.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${routine.deleted
                                ? 'Removed · history kept'
                                : routine.paused
                                ? 'Paused'
                                : 'Available'} · ${preferredWindow(routine.start, routine.end)}\n${routine.steps.length} optional steps · Version ${routine.revision}',
                          ),
                          onTap: () => _action(
                            routine,
                            routine.deleted ? 'history' : 'edit',
                            rows,
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) =>
                                _action(routine, action, rows),
                            itemBuilder: (_) => [
                              if (!routine.deleted)
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit routine'),
                                ),
                              if (!routine.deleted)
                                PopupMenuItem(
                                  value: 'pause',
                                  child: Text(
                                    routine.paused
                                        ? 'Resume routine'
                                        : 'Pause routine',
                                  ),
                                ),
                              if (!routine.deleted)
                                const PopupMenuItem(
                                  value: 'up',
                                  child: Text('Move up'),
                                ),
                              if (!routine.deleted)
                                const PopupMenuItem(
                                  value: 'down',
                                  child: Text('Move down'),
                                ),
                              const PopupMenuItem(
                                value: 'history',
                                child: Text('Version history'),
                              ),
                              if (!routine.deleted)
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Remove routine'),
                                ),
                              if (routine.deleted)
                                const PopupMenuItem(
                                  value: 'restore',
                                  child: Text('Restore, initially paused'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
  );
}
