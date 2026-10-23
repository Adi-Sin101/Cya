import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../data/services/semantic_index.dart';
import '../../providers/memory_providers.dart';
import '../../widgets/local_feature_header.dart';

class LocalModelScreen extends ConsumerStatefulWidget {
  const LocalModelScreen({super.key});
  @override
  ConsumerState<LocalModelScreen> createState() => _LocalModelScreenState();
}

class _LocalModelScreenState extends ConsumerState<LocalModelScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _run(Future<void> Function() work) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await work();
    } on Object {
      if (mounted) {
        setState(
          () => _message =
              'Could not complete that operation. Your saved thoughts are safe. Try again after the current segment finishes.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status =
        ref.watch(semanticStatusProvider).valueOrNull ??
        'Checking local memory index…';
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Local semantic memory')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const LocalFeatureHeader(
              icon: Icons.hub_outlined,
              title: 'Find the connection.',
              description:
                  'Search your words and original voice recordings by meaning, on this phone.',
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.phone_android_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      status,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'EmbeddingGemma 2',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Originals save first. Local indexing follows. No transcript is needed to index audio.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      final installed = await ref
                          .read(embeddingRuntimeProvider)
                          .install();
                      if (!installed) return;
                      await ref
                          .read(preferenceDaoProvider)
                          .write(semanticEnabledKey, 'true');
                      ref.read(semanticIndexProvider).resume();
                      if (mounted) {
                        setState(
                          () => _message =
                              'Local model installed. Saved thoughts will be indexed asynchronously.',
                        );
                      }
                    }),
              icon: const Icon(Icons.folder_open),
              label: const Text('Choose local model file'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      await ref
                          .read(preferenceDaoProvider)
                          .write(semanticEnabledKey, 'true');
                      ref.read(semanticIndexProvider).resume();
                    }),
              child: const Text('Resume local indexing'),
            ),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      await ref
                          .read(preferenceDaoProvider)
                          .write(semanticEnabledKey, 'false');
                      await ref.read(embeddingRuntimeProvider).unload();
                      if (mounted) {
                        setState(
                          () => _message =
                              'Semantic memory paused. Capture, history and keyword search remain available.',
                        );
                      }
                    }),
              child: const Text('Pause and unload model'),
            ),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      await ref.read(semanticIndexProvider).rebuild();
                      if (mounted) {
                        setState(
                          () => _message =
                              'Index rebuild queued. Original thoughts are unchanged.',
                        );
                      }
                    }),
              child: const Text('Retry / rebuild local index'),
            ),
            const SizedBox(height: 16),
            const ExpansionTile(
              tilePadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline_rounded),
              title: Text('Local model and privacy'),
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Use the verified EmbeddingGemma 2 740M LiteRT-LM file (484.6 MB). Cya! checks its exact SHA-256 before installation and use. Choose it from local storage; the app never downloads a model automatically. All inference is on this device, after durable save.',
                  ),
                ),
              ],
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_message!),
              ),
          ],
        ),
      ),
    );
  }
}
