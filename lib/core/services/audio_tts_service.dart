import 'package:flutter_tts/flutter_tts.dart';

class AudioTtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isInitialized = false;

  static final Map<String, String> _languageLocales = {
    'de': 'de-DE',
    'ar': 'ar-SA',
    'en': 'en-US',
    'fr': 'fr-FR',
    'es': 'es-ES',
    'it': 'it-IT',
    'tr': 'tr-TR',
    'pt': 'pt-BR',
    'ru': 'ru-RU',
    'nl': 'nl-NL',
  };

  static Future<void> init() async {
    if (_isInitialized) return;
    await _tts.setSpeechRate(0.45); // سرعة ملائمة لمتعلمي اللغات
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _isInitialized = true;
  }

  /// نطق النص باللغة المستهدفة تلقائياً
  static Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    await init();
    final locale = _languageLocales[languageCode] ?? 'en-US';
    await _tts.setLanguage(locale);
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
}
