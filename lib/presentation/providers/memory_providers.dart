import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Variable;
import '../../core/di/providers.dart';
import '../../domain/entities/memory.dart';
import '../../domain/services/embedding_runtime.dart';
import '../../data/services/semantic_index.dart';
import '../../native/embedding_port.dart';
import '../../native/voice_port.dart';
import '../../domain/audio/captured_audio.dart';
import '../../data/db/audio_mapping.dart';
import '../../data/repositories/focus_repository.dart';
import '../../data/repositories/memory_connections.dart';
export '../../data/repositories/focus_repository.dart' show focusPriorityKey;

final memoriesProvider = StreamProvider.autoDispose
    .family<List<Memory>, ({String query, bool archived})>(
      (ref, filter) => ref
          .watch(memoryRepositoryProvider)
          .watch(query: filter.query, archived: filter.archived),
    );
final memoryHistoryProvider = StreamProvider.autoDispose
    .family<List<Memory>, String>(
      (ref, id) => ref.watch(memoryRepositoryProvider).history(id),
    );
final focusRepositoryProvider = Provider<FocusRepository>(
  (ref) => FocusRepository(ref.watch(databaseProvider)),
);
final focusHistoryProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(focusRepositoryProvider).history(),
);
final focusPriorityProvider = StreamProvider.autoDispose<String?>(
  (ref) => ref.watch(preferenceDaoProvider).watch(focusPriorityKey),
);
final voicePortProvider = Provider<VoicePort>((ref) => const VoicePort());
final memoryConnectionsProvider = Provider<MemoryConnections>(
  (ref) => MemoryConnections(ref.watch(databaseProvider)),
);
final memoryCollectionsProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(memoryConnectionsProvider).collections(),
);
final collectionMemoriesProvider = StreamProvider.autoDispose
    .family<List<Memory>, String>(
      (ref, id) => ref.watch(memoryConnectionsProvider).inCollection(id),
    );
final memoryAssignmentsProvider = StreamProvider.autoDispose.family((
  ref,
  String revision,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.memoryAssignments,
  )..where((a) => a.revisionId.equals(revision))).watch();
});
final audioForMemoryProvider = FutureProvider.autoDispose
    .family<CapturedAudio?, String>((ref, id) async {
      final db = ref.watch(databaseProvider);
      final row = await (db.select(
        db.memoryAttachments,
      )..where((a) => a.memoryId.equals(id))).getSingleOrNull();
      return row?.toCapturedAudio();
    });

final embeddingRuntimeProvider = Provider<EmbeddingRuntime>(
  (ref) => const EmbeddingPort(),
);
final semanticIndexProvider = Provider<SemanticIndex>((ref) {
  final index = SemanticIndex(
    ref.watch(databaseProvider),
    ref.watch(embeddingRuntimeProvider),
    audioFiles: ref.watch(audioAttachmentsProvider),
  );
  final lifecycle = _SemanticLifecycle(index);
  WidgetsBinding.instance.addObserver(lifecycle);
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(lifecycle);
    unawaited(index.dispose());
  });
  if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused) {
    unawaited(index.pause());
  }
  index.start();
  return index;
});
final semanticStatusProvider = StreamProvider.autoDispose<String>((ref) async* {
  final index = ref.watch(semanticIndexProvider);
  yield index.status;
  yield* index.changes;
});
final semanticSearchProvider = FutureProvider.autoDispose
    .family<List<Memory>, ({String query, bool archived})>(
      (ref, filter) => ref
          .watch(semanticIndexProvider)
          .search(filter.query, archived: filter.archived),
    );
final relatedMemoriesProvider = FutureProvider.autoDispose
    .family<List<Memory>, Memory>(
      (ref, source) => ref.watch(semanticIndexProvider).related(source),
    );
final linkedMemoriesProvider = StreamProvider.autoDispose
    .family<List<Memory>, Memory>((ref, source) {
      final db = ref.watch(databaseProvider);
      return db
          .customSelect(
            '''
    SELECT m.id,m.kind,m.captured_at,m.archived_at,r.id AS revision_id,r.revision,r.body,
      l.kind AS connection_kind,l.provenance AS connection_origin
    FROM memory_links l JOIN memory_revisions r ON r.id=CASE WHEN l.from_revision=? THEN l.to_revision ELSE l.from_revision END
    JOIN memories m ON m.id=r.memory_id
    WHERE (l.from_revision=? OR l.to_revision=?) AND l.state='accepted'
  ''',
            variables: [
              for (var i = 0; i < 3; i++)
                Variable.withString(source.revisionId),
            ],
            readsFrom: {db.memoryLinks, db.memoryRevisions, db.memories},
          )
          .watch()
          .map(
            (rows) => rows
                .map(
                  (r) => Memory(
                    id: r.read<String>('id'),
                    text: r.read<String>('body'),
                    revisionId: r.read<String>('revision_id'),
                    revision: r.read<int>('revision'),
                    capturedAt: DateTime.fromMillisecondsSinceEpoch(
                      r.read<int>('captured_at') * 1000,
                    ),
                    archived: r.readNullable<int>('archived_at') != null,
                    kind: r.read<String>('kind'),
                    connectionKind: r.read<String>('connection_kind'),
                    connectionOrigin: r.read<String>('connection_origin'),
                  ),
                )
                .toList(),
          );
    });

/// Created lazily with the worker, including captures made outside Memories.
class _SemanticLifecycle with WidgetsBindingObserver {
  _SemanticLifecycle(this.index);
  final SemanticIndex index;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) unawaited(index.pause());
    if (state == AppLifecycleState.resumed) index.resume();
  }
}
