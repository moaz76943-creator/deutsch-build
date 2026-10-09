import 'package:flutter_tts/flutter_tts.dart';

class OfflineAudioPool {
  static final OfflineAudioPool _instance = OfflineAudioPool._internal();
  factory OfflineAudioPool() => _instance;
  OfflineAudioPool._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Future<void> playWord(String text, {String locale = 'de-DE'}) async {
    try {
      // إيقاف أي صوت جارٍ فوراً لمنع التداخل والتشويش
      await _tts.stop();
      _isPlaying = true;
      await _tts.setLanguage(locale);
      await _tts.setSpeechRate(0.45);
      await _tts.speak(text);
    } catch (_) {
    } finally {
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}
