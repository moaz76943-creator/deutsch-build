import 'package:flutter_tts/flutter_tts.dart';

class FlutterOfflineTtsEngine {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text, {String lang = 'de-DE', double? rate}) async {
    if (text.trim().isEmpty) return;
    try {
      if (rate != null) await _flutterTts.setSpeechRate(rate);
      await _flutterTts.setLanguage(lang);
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  void dispose() {
    _flutterTts.stop();
  }
}

class SafeTtsController {
  static final SafeTtsController _instance = SafeTtsController._internal();
  factory SafeTtsController() => _instance;
  SafeTtsController._internal();

  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text, {String? languageCode, double? rate}) async {
    if (text.trim().isEmpty) return;
    try {
      if (rate != null) await _tts.setSpeechRate(rate);
      await _tts.setLanguage(languageCode ?? 'de-DE');
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal() {
    _initTts();
  }

  final FlutterTts _flutterTts = FlutterTts();

  void _initTts() async {
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  String _mapLanguageCode(String code) {
    switch (code.toLowerCase()) {
      case 'de':
        return 'de-DE';
      case 'en':
        return 'en-US';
      case 'fr':
        return 'fr-FR';
      case 'es':
        return 'es-ES';
      case 'tr':
        return 'tr-TR';
      default:
        return 'de-DE';
    }
  }

  Future<void> speak(String text, {String langCode = 'de'}) async {
    if (text.trim().isEmpty) return;
    try {
      final locale = _mapLanguageCode(langCode);
      await _flutterTts.setLanguage(locale);
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  void dispose() {
    _flutterTts.stop();
  }
}
