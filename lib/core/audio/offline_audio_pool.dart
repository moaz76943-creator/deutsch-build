import 'package:flutter_tts/flutter_tts.dart';
import 'package:deutsch_bilarabi/core/audio/bcp47_locale_registry.dart';

class OfflineAudioPool {
  static final OfflineAudioPool _instance = OfflineAudioPool._internal();
  factory OfflineAudioPool() => _instance;
  OfflineAudioPool._internal() {
    _initTts();
  }

  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  bool _isDisposed = false;
  bool get isPlaying => _isPlaying;

  String _activeLocale = '';
  double _activeSpeechRate = -1.0;

  Future<void> _initTts() async {
    try {
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {}
  }

  Future<void> playWord(
    String text, {
    String locale = 'de-DE', // bcp47 locale
    double speechRate = 0.45,
  }) async {
    if (_isDisposed) return;
    try {
      await _tts.stop();
      _isPlaying = true;

      // Voice check logic (don't play if missing, check regional fallback)
      bool installed = await _tts.isLanguageInstalled(locale) as bool? ?? false;
      String targetLocale = locale;

      if (!installed) {
        String? fallback = Bcp47LocaleRegistry.getFallbackLocale(locale);
        if (fallback != null) {
          bool fbInstalled = await _tts.isLanguageInstalled(fallback) as bool? ?? false;
          if (fbInstalled) {
            targetLocale = fallback;
            installed = true;
          }
        }
      }

      if (!installed) {
        // Voice is not installed locally, reject playback gracefully
        return;
      }

      if (_isDisposed) return; // double check

      // Zero-latency optimization: only update channel state if parameters changed
      if (_activeLocale != targetLocale) {
        await _tts.setLanguage(targetLocale);
        _activeLocale = targetLocale;
      }
      if (_activeSpeechRate != speechRate) {
        await _tts.setSpeechRate(speechRate);
        _activeSpeechRate = speechRate;
      }

      if (_isDisposed) return;
      await _tts.speak(text);
    } catch (_) {
    } finally {
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    if (_isDisposed) return;
    try {
      await _tts.stop();
    } catch (_) {}
    _isPlaying = false;
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _isPlaying = false;
    try {
      _tts.stop();
    } catch (_) {}
    // Release cached audio resources
  }
}
