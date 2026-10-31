import 'package:flutter/services.dart';

import '../domain/pronunciation_models.dart';
import '../domain/services/pronunciation_signal_probe.dart';

final class AndroidPronunciationSignalProbe
    implements PronunciationSignalProbe {
  const AndroidPronunciationSignalProbe();

  static const MethodChannel _channel = MethodChannel(
    'com.deutschbilarabi.app/pronunciation_signal',
  );

  @override
  Future<bool> requestPermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestPermission') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<PronunciationSignalCapture> capture({
    Duration maxDuration = const Duration(milliseconds: 1600),
  }) async {
    try {
      final map = await _channel.invokeMapMethod<Object?, Object?>(
        'capture',
        <String, Object?>{
          'maxDurationMs': maxDuration.inMilliseconds.clamp(500, 2500),
        },
      );
      if (map == null || map['available'] != true) {
        return PronunciationSignalCapture.unavailable(
          map?['reason']?.toString() ?? 'pronunciation_capture_unavailable',
        );
      }
      return PronunciationSignalCapture.available(
        PronunciationSignalFeatures.fromMap(map),
      );
    } on PlatformException catch (error) {
      return PronunciationSignalCapture.unavailable(
        error.code.isEmpty ? 'pronunciation_capture_failed' : error.code,
      );
    } on MissingPluginException {
      return const PronunciationSignalCapture.unavailable(
        'pronunciation_signal_probe_unavailable',
      );
    }
  }
}
