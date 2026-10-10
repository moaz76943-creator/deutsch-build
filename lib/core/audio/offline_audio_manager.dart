import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// محرك الصوت المحلي (Singleton) محمي ضد تسريب الذاكرة وتداخل الأصوات
class OfflineAudioManager {
  static final OfflineAudioManager instance = OfflineAudioManager._init();
  final FlutterTts _flutterTts = FlutterTts();

  OfflineAudioManager._init() {
    _setupTts();
  }

  Future<void> _setupTts() async {
    await _flutterTts.setLanguage("de-DE");
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
  }

  /// نطق الكلمة مع إيقاف أي صوت سابق فوراً لمنع التداخل
  Future<void> speak(String text) async {
    await stop(); 
    await _flutterTts.speak(text);
  }

  /// إيقاف الصوت النشط
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
