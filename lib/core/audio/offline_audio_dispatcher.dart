import 'dart:async';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';
import 'package:deutsch_bilarabi/core/audio/audio_catalog.dart';

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

      final pool = OfflineAudioPool();

      // Attempt exact locale first
      bool capable = await pool.verifyOfflineCapability(bcp47Locale);
      String localeToUse = bcp47Locale;

      // If exact fails, try explicitly approved fallbacks for this language
      if (!capable) {
        final langId = bcp47Locale.split('-')[0];
        final fallbacks = AudioCatalog.getFallbacks(langId);

        for (final fallback in fallbacks) {
          if (thisToken != _currentGenerationToken) return false;
          capable = await pool.verifyOfflineCapability(fallback);
          if (capable) {
            localeToUse = fallback;
            break;
          }
        }
      }

      if (!capable) return false;

      await pool.playWord(
        text,
        locale: localeToUse,
        speechRate: speechRate * 0.5,
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
