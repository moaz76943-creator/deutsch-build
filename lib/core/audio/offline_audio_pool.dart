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
      _isPlaying = true;
      await _tts.setLanguage(locale);
      await _tts.setSpeechRate(0.45);
      await _tts.speak(text);
    } catch (_) {
    } finally {
      _isPlaying = false;
    }
  }

  void dispose() {
    _tts.stop();
  }
}
