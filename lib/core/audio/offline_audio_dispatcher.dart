import 'dart:async';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';

class OfflineAudioDispatcher {
  static int _currentGenerationToken = 0;
  static bool _isPlaying = false;
  static bool get isPlaying => _isPlaying;

  static Future<bool> speakText({
    required String text,
    required String bcp47Locale,
    double speechRate = 0.9,
  }) async {
    final int thisToken = ++_currentGenerationToken;
    _isPlaying = true;
    try {
      if (thisToken != _currentGenerationToken) return false;
      await OfflineAudioPool().playWord(
        text,
        locale: bcp47Locale,
        speechRate: speechRate * 0.5,
        generationToken: thisToken,
      );
      if (thisToken != _currentGenerationToken) return false;
      return true;
    } catch (_) {
      return false;
    } finally {
      if (thisToken == _currentGenerationToken) {
        _isPlaying = false;
      }
    }
  }

  static void stopCurrentAudio() {
    _currentGenerationToken++;
    _isPlaying = false;
    OfflineAudioPool().stop();
  }
}
