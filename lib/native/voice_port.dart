import 'package:flutter/services.dart';
import '../domain/audio/captured_audio.dart';

class VoicePort {
  const VoicePort([this.channel = const MethodChannel('cya/audio')]);
  final MethodChannel channel;
  Future<String> start() async {
    final value = await channel.invokeMapMethod<String, Object?>('start');
    return value!['id']! as String;
  }

  Future<CapturedAudio> stop(String id) async => _audio(
    await channel.invokeMapMethod<String, Object?>('stop', {'id': id}),
  );
  Future<CapturedAudio> recover(String id) async => _audio(
    await channel.invokeMapMethod<String, Object?>('recover', {'id': id}),
  );
  Future<List<Map<Object?, Object?>>> pending(List<String> knownIds) async =>
      await channel.invokeListMethod<Map<Object?, Object?>>('pending', {
        'knownIds': knownIds,
      }) ??
      [];
  Future<void> play(String id, {int offsetMillis = 0}) async {
    final ok = await channel.invokeMethod<bool>('play', {
      'id': id,
      'offsetMillis': offsetMillis,
    });
    if (ok != true) throw StateError('Playback could not start.');
  }

  Future<void> stopPlayback() async {
    try {
      await channel.invokeMethod<void>('stopPlayback');
    } on MissingPluginException {
      /* No audio runtime on unsupported hosts. */
    }
  }

  Future<void> stopAll() async {
    try {
      await channel.invokeMethod<void>('stopAll');
    } on MissingPluginException {
      /* No recorder exists on unsupported hosts. */
    }
  }

  CapturedAudio _audio(Map<String, Object?>? value) {
    if (value == null) throw StateError('No finalized recording returned.');
    final audio = CapturedAudio(
      id: value['id']! as String,
      fileName: value['fileName']! as String,
      sha256: value['sha256']! as String,
      byteLength: value['byteLength']! as int,
      durationMillis: value['durationMillis']! as int,
      capturedAt: DateTime.fromMillisecondsSinceEpoch(
        value['capturedAtMillis']! as int,
      ),
    );
    audio.validate();
    return audio;
  }
}
