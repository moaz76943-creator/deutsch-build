import 'dart:async';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';

class OfflineAudioDispatcher {
  static int _currentGenerationToken = 0;
  static bool get isPlaying => OfflineAudioPool().isPlaying;

  static Future<bool> speakText({
    required String text,
    required String bcp47Locale,
    double speechRate = 0.9,
  }) async {
    final int thisToken = ++_currentGenerationToken;
    try {
      if (thisToken != _currentGenerationToken) return false;
      final result = await OfflineAudioPool().playWord(
        text,
        locale: bcp47Locale,
        speechRate: speechRate * 0.5,
      );
      if (thisToken != _currentGenerationToken) return false;
      return result;
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
    OfflineAudioPool().markPairChange();
  }
}
