import 'package:flutter_tts/flutter_tts.dart';

enum SupportedLanguage {
  german('de-DE', 'الألمانية', '🇩🇪'),
  english('en-US', 'الإنجليزية', '🇬🇧'),
  french('fr-FR', 'الفرنسية', '🇫🇷'),
  spanish('es-ES', 'الإسبانية', '🇪🇸'),
  turkish('tr-TR', 'التركية', '🇹🇷');

  final String localeCode;
  final String titleAr;
  final String flag;
  const SupportedLanguage(this.localeCode, this.titleAr, this.flag);
}

class LanguageHub {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> speakWord(String text, SupportedLanguage lang) async {
    await _tts.setLanguage(lang.localeCode);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(text);
  }
}
