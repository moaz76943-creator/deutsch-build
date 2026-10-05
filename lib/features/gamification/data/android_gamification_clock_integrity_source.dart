import 'package:flutter/services.dart';

import '../domain/gamification_clock_integrity_source.dart';

final class AndroidGamificationClockIntegritySource
    implements GamificationClockIntegritySource {
  const AndroidGamificationClockIntegritySource({
    MethodChannel channel = const MethodChannel(_channelName),
  }) : _channel = channel;

  static const String _channelName =
      'com.deutschbilarabi.app/gamification_clock_integrity';

  final MethodChannel _channel;

  @override
  Future<GamificationClockIntegrityStamp?> read() async {
    try {
      final raw = await _channel.invokeMapMethod<String, Object?>(
        'readStamp',
      );
      if (raw == null) return null;

      final elapsed = _safeInt(raw['elapsedRealtimeMilliseconds']);
      final bootCount = _safeInt(raw['bootCount']);
      if (elapsed == null || bootCount == null) return null;

      final stamp = GamificationClockIntegrityStamp(
        elapsedRealtimeMilliseconds: elapsed,
        bootCount: bootCount,
      );
      return stamp.isValid ? stamp : null;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  static int? _safeInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '');
  }
}
