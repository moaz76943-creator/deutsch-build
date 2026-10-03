import 'package:flutter/services.dart';

import '../domain/services/recorded_audio_player.dart';

final class AndroidRecordedAudioPlayer implements RecordedAudioPlayer {
  AndroidRecordedAudioPlayer({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName =
      'com.deutschbilarabi.app/recorded_audio_player';

  final MethodChannel _channel;
  bool _closed = false;

  @override
  Future<bool> playAsset(String assetPath) async {
    if (_closed || !_isSafeAssetPath(assetPath)) return false;
    try {
      return await _channel.invokeMethod<bool>('playAsset', <String, Object>{
            'assetPath': assetPath,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> stop() async {
    if (_closed) return;
    try {
      await _channel.invokeMethod<void>('stop');
    } on Object {
      // Recorded-audio failure falls back through the unified runtime.
    }
  }

  @override
  Future<void> shutdown() async {
    if (_closed) return;
    await stop();
    _closed = true;
  }

  static bool _isSafeAssetPath(String value) {
    final path = value.trim().replaceAll('\\', '/');
    if (path.isEmpty ||
        path.startsWith('/') ||
        path.contains('../') ||
        path.contains('/..') ||
        path.contains('//')) {
      return false;
    }
    final lower = path.toLowerCase();
    return const <String>{
      '.aac',
      '.flac',
      '.m4a',
      '.mp3',
      '.ogg',
      '.wav',
    }.any(lower.endsWith);
  }
}
