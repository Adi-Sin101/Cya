import 'dart:math';

import 'package:flutter/services.dart';
import '../domain/services/embedding_runtime.dart';

class EmbeddingPort implements EmbeddingRuntime {
  const EmbeddingPort([this.channel = const MethodChannel('cya/embeddings')]);
  final MethodChannel channel;
  @override
  Future<bool> installed() async {
    try {
      return await channel.invokeMethod<bool>('installed') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> install() async =>
      await channel.invokeMethod<bool>('install') ?? false;
  @override
  Future<void> unload() async {
    try {
      await channel.invokeMethod<void>('unload');
    } on MissingPluginException {
      /* Unsupported host has no engine to unload. */
    }
  }

  Future<List<double>> _embed(
    String method,
    Map<String, Object> arguments,
  ) async {
    final raw = await channel.invokeListMethod<num>(method, arguments);
    if (raw == null || raw.length != EmbeddingRuntime.dimensions) {
      throw StateError('Invalid embedding dimensions.');
    }
    final vector = raw.map((v) => v.toDouble()).toList();
    final norm = sqrt(vector.fold<double>(0, (sum, v) => sum + v * v));
    if (!norm.isFinite || norm < 0.000001 || vector.any((v) => !v.isFinite)) {
      throw StateError('The model returned an invalid embedding.');
    }
    return vector.map((v) => v / norm).toList();
  }

  @override
  Future<List<double>> text(String input) =>
      _embed('embedText', {'text': input});
  @override
  Future<List<double>> audio(Uint8List wav) =>
      _embed('embedAudio', {'wav': wav});
}
