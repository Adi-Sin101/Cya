import 'memory_composer.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/router/route_paths.dart';
import '../../../domain/entities/memory.dart';
import '../../providers/memory_providers.dart';
import '../../../domain/audio/pcm_wave.dart';
import '../../../native/voice_port.dart';
import 'connection_picker.dart';
import 'collections_screen.dart';
import 'journal_capture_card.dart';
import 'memory_journal_tile.dart';
import 'memory_connection_map.dart';

/// Original thoughts remain separate from promises, while using the same store.
class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});
  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen>
    with WidgetsBindingObserver {
  late final VoicePort _voice;
  bool _playedAudio = false;
  bool _cleanupPending = false;
  @override
  void initState() {
    super.initState();
    ref.read(semanticIndexProvider);
    _voice = ref.read(voicePortProvider);
    unawaited(
      ref.read(attachmentCleanupProvider).run().catchError((
        Object _,
        StackTrace _,
      ) {
        if (mounted) setState(() => _cleanupPending = true);
      }),
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _playedAudio) {
      unawaited(_voice.stopPlayback());
      _playedAudio = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_playedAudio) unawaited(_voice.stopPlayback());
    super.dispose();
  }

  String _kind = 'all';
  String _query = '';
  bool _archived = false;
  bool _semantic = false;
  String _submittedQuery = '';

  void _searchMeaning() {
    setState(() => _submittedQuery = _query.trim());
    ref.invalidate(
      semanticSearchProvider((query: _submittedQuery, archived: _archived)),
    );
  }

  void _error() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not complete the change. Check your saved thoughts and try again.',
        ),
      ),
    );
  }

  Future<void> _compose([Memory? memory]) async {
    final saved = await showMemoryComposer(context, ref, memory: memory);
    if (saved && mounted && memory == null) await _savedNotice();
  }

  Future<void> _savedNotice() => showSavedMemoryNotice(context, ref);

  Future<void> _playAudio(Memory memory) async {
    try {
      final audio = await ref.read(audioForMemoryProvider(memory.id).future);
      if (audio == null) throw StateError('Original audio is missing.');
      await ref.read(audioAttachmentsProvider).verify(audio);
      if (!mounted) return;
      setState(() => _playedAudio = true);
      await _voice.play(
        audio.id,
        offsetMillis:
            (memory.matchingSegment ?? 0) * PcmWave.segmentSeconds * 1000,
      );
    } on Object {
      if (mounted) {
        setState(() => _playedAudio = false);
        _error();
      }
    }
  }

  Future<void> _focus() async {
    final current = ref.read(focusPriorityProvider).valueOrNull;
    final text = TextEditingController(text: current ?? '');
    final route = DialogRoute<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose your current priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: text,
              autofocus: true,
              maxLength: 160,
              decoration: const InputDecoration(
                hintText: 'What do you want to return to?',
              ),
            ),
            TextButton(
              onPressed: _focusHistory,
              child: const Text('View focus history'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('End focus'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, text.text.trim()),
            child: const Text('Set priority'),
          ),
        ],
      ),
    );
    final value = await Navigator.of(context, rootNavigator: true).push(route);
    await route.completed;
    text.dispose();
    if (value == null || !mounted) return;
    try {
      await ref
          .read(focusRepositoryProvider)
          .select(value, ref.read(clockProvider)());
    } on Object {
      _error();
    }
  }

  Future<void> _focusHistory() => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: Consumer(
          builder: (context, ref, _) => ref
              .watch(focusHistoryProvider)
              .when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) =>
                    const Center(child: Text('Could not read focus history.')),
                data: (sessions) => ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Focus history',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Text(
                      'Your chosen priorities. Earlier history is preserved when you switch or end a session.',
                    ),
                    if (sessions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          'Choose a priority to start your first recorded session.',
                        ),
                      ),
                    for (final session in sessions)
                      ListTile(
                        title: Text(session.priority),
                        subtitle: Text(
                          '${session.startedAt.toLocal()} → ${session.endedAt?.toLocal().toString() ?? 'Active'}',
                        ),
                      ),
                  ],
                ),
              ),
        ),
      ),
    ),
  );

  Future<void> _version(Memory memory) {
    TextSelection? selected;
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preserved version ${memory.revision}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: memory.isAudio && memory.text.isEmpty
                          ? const Text(
                              'Original audio is preserved. Use playback to return to its context.',
                            )
                          : SelectableText(
                              memory.text,
                              onSelectionChanged: (value, _) =>
                                  setSheet(() => selected = value),
                            ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (memory.isAudio)
                        TextButton.icon(
                          onPressed: () => _playAudio(memory),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play original audio'),
                        ),
                      TextButton(
                        onPressed: () => _related(memory),
                        child: const Text('Connections for this version'),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _branch(
                            memory,
                            selection: selected?.isCollapsed == false
                                ? selected
                                : null,
                          );
                        },
                        child: Text(
                          selected?.isCollapsed == false
                              ? 'Branch from selection'
                              : 'Branch from this version',
                        ),
                      ),
                      TextButton(
                        onPressed: () => _history(memory),
                        child: const Text('All versions'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _branch(Memory source, {TextSelection? selection}) async {
    final text = TextEditingController();
    String? error;
    var busy = false;
    final start = selection?.start, end = selection?.end;
    final route = DialogRoute<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialog) => PopScope(
          canPop: !busy,
          child: AlertDialog(
            title: const Text('Explore a separate branch'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Linked to preserved version ${source.revision}. Your source stays unchanged.',
                    ),
                    if (start != null && end != null)
                      Text(
                        source.text.substring(start, end),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    TextField(
                      controller: text,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 8,
                      maxLength: 100000,
                      decoration: InputDecoration(
                        labelText: 'Your exploration',
                        errorText: error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: busy
                    ? null
                    : () => Navigator.pop(dialogContext, false),
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
                              .branch(
                                source.revisionId,
                                text.text,
                                ref.read(clockProvider)(),
                                selectionStart: start,
                                selectionEnd: end,
                              );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, true);
                          }
                        } on Object {
                          if (dialogContext.mounted) {
                            setDialog(() {
                              busy = false;
                              error =
                                  'Write an exploration and select no more than10,000 source characters. Nothing in the source was changed.';
                            });
                          }
                        }
                      },
                child: const Text('Save branch'),
              ),
            ],
          ),
        ),
      ),
    );
    final saved = await Navigator.of(context, rootNavigator: true).push(route);
    await route.completed;
    text.dispose();
    if (saved == true && mounted) await _savedNotice();
  }

  Future<void> _history(Memory memory) => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .75,
        child: Consumer(
          builder: (context, ref, _) => ref
              .watch(memoryHistoryProvider(memory.id))
              .when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const Center(
                  child: Text('Could not read history. Try again.'),
                ),
                data: (history) => ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Thought history',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    for (final revision in history)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              revision.revision == 1
                                  ? 'Original'
                                  : 'Version ${revision.revision}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            SelectableText(
                              revision.text.isEmpty && revision.isAudio
                                  ? 'No caption. Original audio is preserved.'
                                  : revision.text,
                            ),
                            TextButton(
                              onPressed: () => _version(revision),
                              child: const Text('Open this preserved version'),
                            ),
                            if (revision.isAudio)
                              TextButton.icon(
                                onPressed: () => _playAudio(revision),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Play original audio'),
                              ),
                            TextButton(
                              onPressed: () => _related(revision),
                              child: const Text('Connections for this version'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
        ),
      ),
    ),
  );

  Future<void> _action(Memory memory, String action) async {
    if (action == 'branch') {
      await _branch(memory);
      return;
    }
    if (action == 'connect') {
      await showConnectionPicker(context, memory);
      ref.invalidate(relatedMemoriesProvider(memory));
      return;
    }
    if (action == 'related') {
      await _related(memory);
      return;
    }
    if (action == 'edit') {
      await _compose(memory);
      return;
    }
    if (action == 'history') {
      await _history(memory);
      return;
    }
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete this thought permanently?'),
          content: const Text(
            'This removes every version, original audio, its semantic index and connections to it. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep thought'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete permanently'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    try {
      final repo = ref.read(memoryRepositoryProvider);
      if (action == 'delete') {
        if (memory.isAudio) await _voice.stopPlayback();
        await repo.deleteMemory(memory.id);
      } else {
        await repo.archive(
          memory.id,
          !memory.archived,
          ref.read(clockProvider)(),
        );
      }
    } on Object {
      _error();
    }
  }

  Future<void> _related(Memory source) => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .75,
        child: Consumer(
          builder: (context, ref, _) {
            final linked =
                ref.watch(linkedMemoriesProvider(source)).valueOrNull ??
                <Memory>[];
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Connections',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Source version ${source.revision}. Connections retain exact versions; later edits do not replace them.',
                ),
                TextButton.icon(
                  onPressed: () => showConnectionPicker(context, source),
                  icon: const Icon(Icons.add_link),
                  label: const Text('Create an explicit connection'),
                ),
                MemoryConnectionMap(
                  source: source,
                  links: linked,
                  onOpen: _version,
                ),
                for (final memory in linked)
                  ListTile(
                    title: Text(
                      memory.displayText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${memory.connectionOrigin == 'model' ? 'Reviewed model suggestion' : 'Your explicit link'} · ${memory.connectionKind} · Version ${memory.revision}',
                    ),
                    onTap: () => _version(memory),
                  ),
                ...ref
                    .watch(memoryAssignmentsProvider(source.revisionId))
                    .when(
                      loading: () => <Widget>[const LinearProgressIndicator()],
                      error: (_, _) => <Widget>[
                        const Text('Could not read organization links.'),
                      ],
                      data: (assignments) => <Widget>[
                        for (final assignment in assignments)
                          ListTile(
                            title: Text(
                              assignment.context,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${assignment.kind == 'intention' ? 'Existing promise' : 'Topic / project'} · Your link from version ${source.revision}',
                            ),
                            onTap: () {
                              if (assignment.intentionId != null) {
                                Navigator.pop(context);
                                this.context.push(
                                  RoutePaths.promiseDetail(
                                    assignment.intentionId!,
                                  ),
                                );
                              } else {
                                final found =
                                    (ref
                                                .read(memoryCollectionsProvider)
                                                .valueOrNull ??
                                            [])
                                        .where(
                                          (c) =>
                                              c.id == assignment.collectionId,
                                        )
                                        .toList();
                                if (found.isNotEmpty) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => CollectionMemoriesScreen(
                                        collection: found.first,
                                        onOpen: _version,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            trailing: IconButton(
                              tooltip: 'Remove this link',
                              icon: const Icon(Icons.link_off),
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(memoryConnectionsProvider)
                                      .unassign(
                                        assignment.id,
                                        ref.read(clockProvider)(),
                                      );
                                } on Object {
                                  _error();
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                const SizedBox(height: 16),
                const Text(
                  'These thoughts may be related. Similarity is a suggestion; your originals stay separate.',
                ),
                ref
                    .watch(relatedMemoriesProvider(source))
                    .when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const Text(
                        'Could not read suggestions. Try again after indexing.',
                      ),
                      data: (items) => Column(
                        children: [
                          if (items.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No new suggestions. Saved thoughts need local indexing first.',
                              ),
                            ),
                          for (final memory in items)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memory.displayText,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        TextButton(
                                          onPressed: () => _history(memory),
                                          child: const Text('View history'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              await ref
                                                  .read(semanticIndexProvider)
                                                  .reviewRelated(
                                                    source,
                                                    memory,
                                                    accepted: true,
                                                  );
                                              ref.invalidate(
                                                relatedMemoriesProvider(source),
                                              );
                                            } on Object {
                                              _error();
                                            }
                                          },
                                          child: const Text(
                                            'Accept connection',
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              await ref
                                                  .read(semanticIndexProvider)
                                                  .reviewRelated(
                                                    source,
                                                    memory,
                                                    accepted: false,
                                                  );
                                              ref.invalidate(
                                                relatedMemoriesProvider(source),
                                              );
                                            } on Object {
                                              _error();
                                            }
                                          },
                                          child: const Text('Dismiss'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final words = ref.watch(
      memoriesProvider((query: _query, archived: _archived)),
    );
    final memories = _semantic
        ? (_submittedQuery.isEmpty
              ? const AsyncValue<List<Memory>>.data([])
              : ref.watch(
                  semanticSearchProvider((
                    query: _submittedQuery,
                    archived: _archived,
                  )),
                ))
        : words;
    final priority = ref.watch(focusPriorityProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
        actions: [
          if (_playedAudio)
            IconButton(
              onPressed: () async {
                await _voice.stopPlayback();
                if (mounted) setState(() => _playedAudio = false);
              },
              tooltip: 'Stop audio playback',
              icon: const Icon(Icons.stop_rounded),
            ),
          IconButton(
            onPressed: () => context.push(RoutePaths.localModel),
            tooltip: 'Local semantic model',
            icon: const Icon(Icons.memory_outlined),
          ),
          IconButton(
            onPressed: () => setState(() => _archived = !_archived),
            tooltip: _archived
                ? 'Show active thoughts'
                : 'Show archived thoughts',
            icon: Icon(
              _archived ? Icons.unarchive_outlined : Icons.archive_outlined,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your words. Your voice.',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep the moment. Find it again.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  const JournalCaptureCard(),
                  if (_cleanupPending)
                    TextButton(
                      onPressed: () async {
                        try {
                          await ref.read(attachmentCleanupProvider).run();
                          if (mounted) setState(() => _cleanupPending = false);
                        } on Object {
                          _error();
                        }
                      },
                      child: const Text('Retry pending audio file cleanup'),
                    ),
                  if (priority != null && priority.isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.center_focus_strong),
                      title: Text(
                        'Your priority: $priority',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: _focus,
                    ),
                  const SizedBox(height: 20),
                  SearchBar(
                    elevation: const WidgetStatePropertyAll<double>(0),
                    backgroundColor: WidgetStatePropertyAll(
                      theme.colorScheme.surfaceContainerLow,
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    hintText: _semantic
                        ? 'Find a memory by meaning'
                        : 'Search your words',
                    leading: const Icon(Icons.search_rounded),
                    onChanged: (value) => setState(() => _query = value),
                    onSubmitted: _semantic ? (_) => _searchMeaning() : null,
                    trailing: _semantic
                        ? [
                            IconButton(
                              onPressed: _searchMeaning,
                              tooltip: 'Search by meaning',
                              icon: const Icon(Icons.arrow_forward_rounded),
                            ),
                          ]
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Keyword'),
                        selected: !_semantic,
                        onSelected: (_) => setState(() => _semantic = false),
                      ),
                      ChoiceChip(
                        label: const Text('Semantic'),
                        selected: _semantic,
                        onSelected: (_) => setState(() => _semantic = true),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    CollectionsScreen(onOpen: _version),
                              ),
                            ),
                        icon: const Icon(Icons.account_tree_outlined, size: 20),
                        label: const Text('Topics and projects'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final kind in const [
                        ('all', 'All memories'),
                        ('audio', 'Voice'),
                        ('text', 'Written'),
                      ])
                        FilterChip(
                          label: Text(kind.$2),
                          selected: _kind == kind.$1,
                          onSelected: (_) => setState(() => _kind = kind.$1),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _archived ? 'Archived thoughts' : 'Your journal',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          memories.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      _semantic
                          ? 'Semantic search is unavailable. Check the local model or use Keyword search.'
                          : 'Could not read memories. Try again.',
                    ),
                    TextButton(
                      onPressed: () {
                        if (_semantic) {
                          context.push(RoutePaths.localModel);
                        } else {
                          ref.invalidate(
                            memoriesProvider((
                              query: _query,
                              archived: _archived,
                            )),
                          );
                        }
                      },
                      child: Text(_semantic ? 'Local semantic model' : 'Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (all) {
              final items = all
                  .where((m) => _kind == 'all' || m.kind == _kind)
                  .toList();
              if (items.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 32,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _kind == 'audio'
                              ? Icons.mic_none_rounded
                              : Icons.auto_stories_outlined,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _semantic && _submittedQuery.isEmpty
                              ? 'Enter a query and tap Search.'
                              : _query.isNotEmpty
                              ? 'No matching thoughts.'
                              : _archived
                              ? 'No archived thoughts.'
                              : 'Keep a thought here. No tags or reminders required.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final memory = items[index];
                    return MemoryJournalTile(
                      key: ValueKey('memory-${memory.id}'),
                      memory: memory,
                      onOpen: () => _history(memory),
                      onPlay: () => _playAudio(memory),
                      onAction: (action) => _action(memory, action),
                    );
                  },
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
