import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite returns a bounded Ogg/Opus blob; no per-clip files are extracted.
/// The SQLite driver and platform channel may copy bytes (not literal zero-copy).
abstract class EmbeddedOpusSource {
  Future<Uint8List?> read(String clipId);
}

class SqliteEmbeddedOpusSource implements EmbeddedOpusSource {
  SqliteEmbeddedOpusSource(this.database);
  final Database database;

  @override
  Future<Uint8List?> read(String clipId) async {
    if (clipId.isEmpty || clipId.length > 128) return null;
    try {
      final rows = await database.rawQuery(
        'SELECT opus_bytes FROM audio_blobs WHERE clip_id = ? LIMIT 1',
        <Object?>[clipId],
      );
      if (rows.isEmpty) return null;
      final raw = rows.single['opus_bytes'];
      return raw is Uint8List ? raw : null;
    } on DatabaseException catch (error) {
      if (error.toString().contains('no such table') ||
          error.toString().contains('no such column')) return null;
      rethrow;
    }
  }
}

abstract class EmbeddedOpusPlayer {
  Future<bool> play(Uint8List oggOpus);
  Future<void> stop();
}

class AndroidEmbeddedOpusPlayer implements EmbeddedOpusPlayer {
  const AndroidEmbeddedOpusPlayer();
  static const channel = MethodChannel(
      'com.deutschbilarabi.app/recorded_audio_player');

  @override
  Future<bool> play(Uint8List oggOpus) async {
    try {
      return await channel.invokeMethod<bool>(
        'playOpusBytes', <String, Object>{'bytes': oggOpus},
      ) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> stop() async {
    await channel.invokeMethod<void>('stop');
  }
}

class EmbeddedAudioStreamer {
  EmbeddedAudioStreamer({
    required EmbeddedOpusSource source,
    EmbeddedOpusPlayer? player,
  }) : _source = source, _player = player ?? const AndroidEmbeddedOpusPlayer();

  static const int maximumClipBytes = 8 * 1024 * 1024;
  final EmbeddedOpusSource _source;
  final EmbeddedOpusPlayer _player;

  Future<bool> playClip(String clipId) async {
    final bytes = await _source.read(clipId);
    if (bytes == null) return false;
    return playBytes(bytes);
  }

  /// Accepts Ogg-wrapped Opus, not raw codec frames.
  Future<bool> playBytes(Uint8List data) async {
    if (data.length < 8 || data.length > maximumClipBytes ||
        data[0] != 0x4f || data[1] != 0x67 ||
        data[2] != 0x67 || data[3] != 0x53) return false;
    return _player.play(data);
  }

  Future<void> stop() => _player.stop();
}
