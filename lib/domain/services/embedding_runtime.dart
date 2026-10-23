import 'dart:typed_data';

abstract interface class EmbeddingRuntime {
  static const modelHash =
      'e7a8a2204b91e0f96e92960e84a09a89212e1633dcb7575a9bf3378b4df77f4c';
  static const dimensions = 256;
  static const version =
      '$modelHash/litertlm-0.18.0/cpu-f32/text-audio/256/search-v1/text1000-audio20';
  Future<bool> installed();
  Future<bool> install();
  Future<List<double>> text(String input);
  Future<List<double>> audio(Uint8List wav);
  Future<void> unload();
}
