import 'dart:async';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';

class OfflineAudioDispatcher {
  static int _currentGenerationToken = 0;
  static bool get isPlaying => OfflineAudioPool().isPlaying;

  static Future<bool> speakText({
    required String text,
    required String bcp47Locale,
    double speechRate = 0.9,
    double pitch = 1.0,
  }) async {
    final int thisToken = ++_currentGenerationToken;
    try {
      if (thisToken != _currentGenerationToken) return false;
      await OfflineAudioPool().playWord(
        text,
        locale: bcp47Locale,
        speechRate: speechRate * 0.5,
        // pitch is not natively supported by the broken playWord yet, but we will fix that next.
      );
      if (thisToken != _currentGenerationToken) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  static void stopCurrentAudio() {
    _currentGenerationToken++;
    OfflineAudioPool().stop();
  }

  static void markPairChange() {
    _currentGenerationToken++;
    OfflineAudioPool().stop();
  }
}
