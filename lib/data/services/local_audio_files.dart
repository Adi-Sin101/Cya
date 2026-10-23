import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/audio/audio_attachments.dart';
import '../../domain/audio/captured_audio.dart';
import '../../domain/audio/pcm_wave.dart';

class LocalAudioFiles implements AudioAttachments {
  LocalAudioFiles({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;
  final Future<Directory> Function() _directory;
  final _verified = <String>{};

  Future<File> _file(String fileName) async {
    if (!CapturedAudio.validFileName(fileName)) {
      throw const FormatException('Invalid attachment reference.');
    }
    final root = await _directory();
    return File(
      '${root.path}${Platform.pathSeparator}memory_audio${Platform.pathSeparator}$fileName',
    );
  }

  @override
  Future<void> verify(CapturedAudio audio) async {
    audio.validate();
    final source = await _file(audio.fileName);
    final stat = await source.stat();
    if (stat.type != FileSystemEntityType.file ||
        stat.size != audio.byteLength) {
      throw const FormatException('Recording file is missing or incomplete.');
    }
    final signature =
        '${audio.fileName}:${audio.sha256}:${stat.modified.microsecondsSinceEpoch}:${stat.size}';
    if (_verified.contains(signature)) return;
    final handle = await source.open();
    try {
      final bytes = PcmWave.validateHeader(await handle.read(44), stat.size);
      if (bytes * 1000 ~/ PcmWave.bytesPerSecond != audio.durationMillis) {
        throw const FormatException(
          'Recording duration does not match its samples.',
        );
      }
    } finally {
      await handle.close();
    }
    if ((await sha256.bind(source.openRead()).first).toString() !=
        audio.sha256) {
      throw const FormatException('Recording integrity check failed.');
    }
    _verified.add(signature);
  }

  @override
  Future<Uint8List> segment(CapturedAudio audio, int segment) async {
    await verify(audio);
    final dataBytes = audio.byteLength - 44;
    final offset = segment * PcmWave.segmentBytes;
    if (segment < 0 || offset >= dataBytes) {
      throw RangeError('Invalid audio segment.');
    }
    final source = await (await _file(audio.fileName)).open();
    try {
      await source.setPosition(44 + offset);
      final wanted = min(PcmWave.segmentBytes, dataBytes - offset);
      final pcm = Uint8List(wanted);
      var read = 0;
      while (read < wanted) {
        final chunk = await source.read(wanted - read);
        if (chunk.isEmpty) {
          throw const FormatException('Recording ended unexpectedly.');
        }
        pcm.setRange(read, read + chunk.length, chunk);
        read += chunk.length;
      }
      return PcmWave.wrap(pcm);
    } finally {
      await source.close();
    }
  }

  @override
  Future<void> delete(String fileName) async {
    final source = await _file(fileName);
    final stem = source.path.substring(0, source.path.length - 4);
    for (final suffix in ['wav', 'part', 'json', 'recovering']) {
      final file = File('$stem.$suffix');
      if (await file.exists()) await file.delete();
    }
    _verified.removeWhere((entry) => entry.startsWith('$fileName:'));
  }

  @override
  Future<void> eraseAll() async {
    final root = await _directory();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}memory_audio',
    );
    if (await directory.exists()) {
      await for (final entry in directory.list(followLinks: false)) {
        await entry.delete(recursive: true);
      }
    }
    _verified.clear();
  }
}
