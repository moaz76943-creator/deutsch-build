import 'package:flutter_tts/flutter_tts.dart';

class OfflineAudioManager {
  static final OfflineAudioManager instance = OfflineAudioManager._init();
  final FlutterTts _flutterTts = FlutterTts();
  String _currentLocale = 'de-DE';

  OfflineAudioManager._init() {
    _setupTts();
  }

  Future<void> _setupTts() async {
    try {
      await _flutterTts.setLanguage('de-DE');
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setVolume(1.0);
    } catch (_) {}
  }

  Future<void> speak(String text, {String locale = 'de-DE', double rate = 0.4}) async {
    try {
      await stop();
      if (_currentLocale != locale) {
        await _flutterTts.setLanguage(locale);
        _currentLocale = locale;
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
