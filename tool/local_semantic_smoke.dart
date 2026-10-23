// Developer-only real-artifact smoke entry point. Builds under Cya!'s actual
// Android host/bridge, but uses an isolated in-memory fixture, never user rows.
// Install the exact pinned model explicitly first; no download path exists.
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cya/data/db/cya_database.dart';
import 'package:cya/data/repositories/drift_memory_repository.dart';
import 'package:cya/data/services/semantic_index.dart';
import 'package:cya/data/services/local_audio_files.dart';
import 'package:cya/domain/audio/captured_audio.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cya/native/embedding_port.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = ValueNotifier('Running local semantic smoke…');
  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ValueListenableBuilder(
              valueListenable: state,
              builder: (context, value, _) => SelectableText(value),
            ),
          ),
        ),
      ),
    ),
  );
  final db = CyaDatabase.memory();
  const runtime = EmbeddingPort();
  final files = LocalAudioFiles();
  final index = SemanticIndex(db, runtime, audioFiles: files);
  File? fixture;
  try {
    if (!await runtime.installed()) {
      throw StateError(
        'Install the pinned local model before this diagnostic.',
      );
    }
    final repo = DriftMemoryRepository(db, audioFiles: files);
    final recordingId = 'e7a8a220-4b91-40f9-8e92-960e84a09a89';
    final bytes = _tone();
    final digest = sha256.convert(bytes).toString();
    fixture = File(
      '${(await getApplicationSupportDirectory()).path}/memory_audio/$recordingId.wav',
    );
    if (await fixture.exists()) {
      throw StateError(
        'Diagnostic fixture already exists; refusing overwrite.',
      );
    }
    await fixture.parent.create(recursive: true);
    await fixture.writeAsBytes(bytes, flush: true);
    final audioMemory = await repo.captureAudio(
      CapturedAudio(
        id: recordingId,
        fileName: '$recordingId.wav',
        sha256: digest,
        byteLength: bytes.length,
        durationMillis: 1000,
        capturedAt: DateTime.now(),
      ),
    );
    final book = await repo.captureText(
      'আগামীকাল book porbo. I want to read my book and reflect on its ideas.',
      DateTime.now(),
    );
    await repo.captureText(
      'I enjoy brewing tea in the morning with fresh ginger.',
      DateTime.now(),
    );
    await db.preferenceDao.write(semanticEnabledKey, 'true');
    final indexing = Stopwatch()..start();
    await index.start();
    final deadline = DateTime.now().add(const Duration(minutes: 3));
    while (true) {
      final jobs = await db.select(db.memoryJobs).get();
      if (jobs.any((j) => j.state == 'failed')) {
        throw StateError('Actual model indexing failed.');
      }
      if (jobs.every((j) => j.state == 'complete')) break;
      if (DateTime.now().isAfter(deadline)) {
        throw StateError('Actual indexing timed out.');
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    indexing.stop();
    final search = Stopwatch()..start();
    final results = await index.search('reading a book');
    search.stop();
    if (results.isEmpty || results.first.id != book) {
      throw StateError(
        'Synthetic text retrieval smoke did not rank its expected source first.',
      );
    }
    final audio = await runtime.audio(_tone());
    if (audio.length != 256 || audio.any((v) => !v.isFinite)) {
      throw StateError('Actual raw audio path failed.');
    }
    final query = await runtime.text(
      'task: search result | query: a high pitched whistling tone',
    );
    final cosine = List.generate(
      256,
      (i) => audio[i] * query[i],
    ).fold<double>(0, (a, b) => a + b);
    final audioResults = await index.search('a high pitched whistling tone');
    if (!audioResults.any((m) => m.id == audioMemory && m.isAudio)) {
      throw StateError('Direct text query did not return raw-audio memory.');
    }
    if (sha256.convert(await fixture.readAsBytes()).toString() != digest) {
      throw StateError('Audio original changed.');
    }
    await repo.deleteMemory(audioMemory);
    if (await fixture.exists() ||
        (await db.select(db.memoryAttachments).get()).isNotEmpty) {
      throw StateError('Audio deletion cleanup failed.');
    }
    fixture = null;
    await index.pause();
    await db.preferenceDao.write(semanticEnabledKey, 'false');
    await repo.captureText('Saved with the model disabled.', DateTime.now());
    if ((await repo.watch(query: 'disabled').first).length != 1) {
      throw StateError('Disabled-model fallback failed.');
    }
    final report = {
      'passed': true,
      'indexedTextMemories': 2,
      'indexingMs': indexing.elapsedMilliseconds,
      'searchMs': search.elapsedMilliseconds,
      'textRetrievalExpectedFirst': true,
      'rawAudioDimensions': audio.length,
      'rawAudioWithoutTranscript': true,
      'rawAudioMemoryIndexAndTextQuery': true,
      'audioOriginalIntegrityAndDeletion': true,
      'textAudioCosine': cosine,
      'disabledModelCaptureAndKeyword': true,
      'scope':
          'synthetic functional smoke; not multilingual quality or phone performance acceptance',
    };
    state.value = jsonEncode(report);
    debugPrint('CYA_SEMANTIC_SMOKE=${jsonEncode(report)}');
  } on Object catch (error) {
    state.value = 'CYA_SEMANTIC_SMOKE_FAILED: $error';
    debugPrint(state.value);
  } finally {
    if (fixture != null && await fixture.exists()) {
      await files.delete(fixture.uri.pathSegments.last);
    }
    await index.dispose();
    await runtime.unload();
    await db.close();
  }
}

Uint8List _tone() {
  final out = Uint8List(44 + 32000);
  final data = ByteData.sublistView(out);
  void tag(int at, String text) =>
      out.setRange(at, at + text.length, ascii.encode(text));
  tag(0, 'RIFF');
  data.setUint32(4, 32036, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, 16000, Endian.little);
  data.setUint32(28, 32000, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  tag(36, 'data');
  data.setUint32(40, 32000, Endian.little);
  for (var i = 0; i < 16000; i++) {
    data.setInt16(
      44 + i * 2,
      (sin(2 * pi * 1000 * i / 16000) * 5000).round(),
      Endian.little,
    );
  }
  return out;
}
