import 'package:flutter_tts/flutter_tts.dart';

class OfflineAudioPool {
  static final OfflineAudioPool _instance = OfflineAudioPool._internal();
  factory OfflineAudioPool() => _instance;
  OfflineAudioPool._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  String _activeLocale = '';
  double _activeSpeechRate = -1.0;

  Future<void> playWord(
    String text, {
    String locale = 'de-DE',
    double speechRate = 0.45,
  }) async {
    try {
      await _tts.stop();
      _isPlaying = true;

      // Zero-latency optimization: only update channel state if parameters changed
      if (_activeLocale != locale) {
        await _tts.setLanguage(locale);
        _activeLocale = locale;
      }
      if (_activeSpeechRate != speechRate) {
        await _tts.setSpeechRate(speechRate);
        _activeSpeechRate = speechRate;
      }

      await _tts.speak(text);
    } catch (_) {
    } finally {
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _isPlaying = false;
  }

  void dispose() {
    // Release cached audio resources
  }
}
