import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/audio/captured_audio.dart';
import '../../../native/voice_port.dart';
import '../../providers/memory_providers.dart';
import '../../providers/reliability_providers.dart';
import 'voice_recording_visual.dart';

Future<bool?> showVoiceCapture(BuildContext context) =>
    showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .92,
      ),
      isDismissible: false,
      enableDrag: false,
      showDragHandle: true,
      builder: (_) => const _VoiceCapture(),
    );

class _VoiceCapture extends ConsumerStatefulWidget {
  const _VoiceCapture();
  @override
  ConsumerState<_VoiceCapture> createState() => _VoiceCaptureState();
}

class _VoiceCaptureState extends ConsumerState<_VoiceCapture>
    with WidgetsBindingObserver {
  late final VoicePort _voice;
  bool _played = false;
  bool _busy = false;
  bool _recording = false;
  String? _id;
  CapturedAudio? _audio;
  String? _error;
  int _seconds = 0;
  Timer? _timer;
  List<Map<Object?, Object?>> _pending = [];

  @override
  void initState() {
    super.initState();
    _voice = ref.read(voicePortProvider);
    WidgetsBinding.instance.addObserver(this);
    _loadPending();
  }

  Future<void> _loadPending() async {
    try {
      final db = ref.read(databaseProvider);
      final known = (await db.select(db.memoryAttachments).get())
          .map((a) => a.id)
          .toList();
      if (!mounted) return;
      final values = await ref.read(voicePortProvider).pending(known);
      if (mounted) setState(() => _pending = values);
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'Could not check interrupted recordings. Local voice capture requires Android.',
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _recording && !_busy) {
      unawaited(_finish());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    if (_played) unawaited(_voice.stopPlayback());
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final port = ref.read(voicePortProvider);
    try {
      final id = await port.start();
      if (!mounted) {
        unawaited(
          port
              .stop(id)
              .then<void>((_) {}, onError: (Object _, StackTrace _) {}),
        );
        return;
      }
      setState(() {
        _id = id;
        _recording = true;
        _seconds = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _seconds++);
        if (_seconds >= 300 && !_busy) unawaited(_finish());
      });
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'Could not start recording. Check microphone permission and available storage. Typed capture still works.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _finish({bool save = false}) async {
    final id = _id;
    if (id == null || _busy) return;
    _timer?.cancel();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final audio = await ref.read(voicePortProvider).stop(id);
      if (mounted) {
        setState(() {
          _audio = audio;
          _recording = false;
        });
      }
      if (save && mounted) {
        await ref.read(memoryRepositoryProvider).captureAudio(audio);
        if (mounted) Navigator.pop(context, true);
      }
    } on Object {
      if (mounted) {
        setState(() {
          _recording = false;
          _error = _audio != null
              ? 'Your original recording is kept locally, but saving to the list failed. Try Save again.'
              : 'Could not finalize this recording. It may be recoverable when you reopen voice capture.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _keepForLater() async {
    if (_recording) await _finish();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Original recording kept locally. Reopen voice capture to recover it.',
        ),
      ),
    );
    Navigator.pop(context, false);
  }

  Future<void> _save() async {
    final audio = _audio;
    if (audio == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(memoryRepositoryProvider).captureAudio(audio);
      if (mounted) Navigator.pop(context, true);
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'Could not save to the memory list. Your original recording is still on this device. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _discard() async {
    if (_id == null) {
      Navigator.pop(context, false);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard this recording?'),
        content: const Text('This removes the unsaved audio from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    _timer?.cancel();
    try {
      if (_recording) {
        try {
          await ref.read(voicePortProvider).stop(_id!);
        } on Object {
          /* Delete the owned interrupted file as explicitly requested. */
        }
      }
      await ref.read(audioAttachmentsProvider).delete('$_id.wav');
      if (mounted) Navigator.pop(context, false);
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'Could not discard the local file. It remains on this device.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recover(String id) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final audio = await ref.read(voicePortProvider).recover(id);
      if (mounted) {
        setState(() {
          _id = id;
          _audio = audio;
          _recording = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(
          () => _error =
              'That recording could not be recovered. Its original file has been kept.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _play() async {
    final audio = _audio;
    if (audio == null) return;
    try {
      await ref.read(audioAttachmentsProvider).verify(audio);
      if (!mounted) return;
      _played = true;
      await _voice.play(audio.id);
    } on Object {
      if (mounted) {
        setState(() => _error = 'Could not play the original recording.');
      }
    }
  }

  Future<void> _discardPending(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard this unfinished recording?'),
        content: const Text(
          'This deletes its original local audio. It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(audioAttachmentsProvider).delete('$id.wav');
      await _loadPending();
    } on Object {
      if (mounted) {
        setState(
          () => _error = 'Could not discard that file. It remains local.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy && _id == null,
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your voice journal',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            VoiceRecordingVisual(
              seconds: _audio != null
                  ? _audio!.durationMillis ~/ 1000
                  : _seconds,
              recording: _recording,
              ready: _audio != null,
            ),
            const SizedBox(height: 24),
            if (_id == null)
              FilledButton.icon(
                onPressed: _busy ? null : _start,
                icon: const Icon(Icons.mic),
                label: const Text('Start recording'),
              ),
            if (_recording) ...[
              FilledButton(
                onPressed: _busy ? null : () => _finish(save: true),
                child: const Text('Stop and save'),
              ),
              TextButton(
                onPressed: _busy ? null : () => _finish(),
                child: const Text('Stop to review'),
              ),
            ],
            if (_audio != null) ...[
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _busy ? null : _play,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play original'),
                  ),
                  TextButton(
                    onPressed: () => ref.read(voicePortProvider).stopPlayback(),
                    child: const Text('Stop playback'),
                  ),
                ],
              ),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: const Text('Save voice thought'),
              ),
            ],
            const SizedBox(height: 16),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.phone_android_rounded, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Original audio stays on this device. No transcript needed.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Audio files are app-private but are not encrypted at rest.',
              style: TextStyle(fontSize: 12),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_error!),
              ),
            if (_error != null && _id == null)
              TextButton.icon(
                onPressed: _busy
                    ? null
                    : () async {
                        final opened = await ref
                            .read(deviceReliabilityPortProvider)
                            .openAppSettings();
                        if (!opened && mounted) {
                          setState(
                            () => _error =
                                'Open Android Settings > Apps > Cya! > Permissions to allow Microphone, then try again.',
                          );
                        }
                      },
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Microphone permission settings'),
              ),
            TextButton(
              onPressed: _busy ? null : _discard,
              child: Text(_id == null ? 'Close' : 'Discard recording'),
            ),
            if (_id != null)
              TextButton(
                onPressed: _busy ? null : _keepForLater,
                child: const Text('Keep locally for later'),
              ),
            if (_id == null && _pending.isNotEmpty) ...[
              const Divider(),
              const Text('Interrupted or unsaved recordings'),
              for (final item in _pending)
                ListTile(
                  title: Text(
                    'Local recording · ${(item['durationMillis']! as int) ~/ 1000}s',
                  ),
                  subtitle: Text(
                    DateTime.fromMillisecondsSinceEpoch(
                      item['capturedAtMillis']! as int,
                    ).toLocal().toString().split('.').first,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => _recover(item['id']! as String),
                        child: const Text('Recover'),
                      ),
                      IconButton(
                        onPressed: _busy
                            ? null
                            : () => _discardPending(item['id']! as String),
                        tooltip: 'Discard unfinished recording',
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    ),
  );
}
