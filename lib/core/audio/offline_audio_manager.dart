import 'package:flutter_tts/flutter_tts.dart';
import 'package:deutsch_bilarabi/core/audio/bcp47_locale_registry.dart';

class OfflineAudioManager {
  static final OfflineAudioManager instance = OfflineAudioManager._init();
  final FlutterTts _flutterTts = FlutterTts();
  String _currentLocale = 'de-DE';
  double _currentRate = 0.4;

  OfflineAudioManager._init() {
    _setupTts();
  }

  Future<void> _setupTts() async {
    try {
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.setLanguage('de-DE');
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setVolume(1.0);
    } catch (_) {}
  }

  Future<void> speak(String text, {String locale = 'de-DE', double rate = 0.4}) async {
    try {
      await stop();

      bool installed = await _flutterTts.isLanguageInstalled(locale) as bool? ?? false;
      String targetLocale = locale;

      if (!installed) {
        String? fallback = Bcp47LocaleRegistry.getFallbackLocale(locale);
        if (fallback != null) {
          bool fbInstalled = await _flutterTts.isLanguageInstalled(fallback) as bool? ?? false;
          if (fbInstalled) {
            targetLocale = fallback;
            installed = true;
          }
        }
      }

      if (!installed) return;

      if (_currentLocale != targetLocale) {
        await _flutterTts.setLanguage(targetLocale);
        _currentLocale = targetLocale;
      }
      if (_currentRate != rate) {
          await _flutterTts.setSpeechRate(rate);
          _currentRate = rate;
      }
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
