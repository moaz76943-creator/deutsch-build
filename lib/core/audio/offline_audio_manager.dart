import 'package:flutter_tts/flutter_tts.dart';
import 'package:deutsch_bilarabi/core/audio/audio_generation_tracker.dart';

class OfflineAudioManager {
  static final OfflineAudioManager instance = OfflineAudioManager._init();
  final FlutterTts _flutterTts = FlutterTts();
  String _currentLocale = 'de-DE';
  final AudioGenerationTracker _generationTracker = AudioGenerationTracker();

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

  Future<bool> verifyOfflineCapability(String bcp47) async {
    try {
      final isAvailable = await _flutterTts.isLanguageAvailable(bcp47);
      return isAvailable == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> speak(String text, {String locale = 'de-DE', double rate = 0.4}) async {
    try {
      await stop();

      final bool isCapable = await verifyOfflineCapability(locale);
      if (!isCapable) return;

      final int currentGen = _generationTracker.nextGeneration();

      if (_currentLocale != locale) {
        await _flutterTts.setLanguage(locale);
        _currentLocale = locale;
      }
      await _flutterTts.setSpeechRate(rate);

      if (_generationTracker.isCurrent(currentGen)) {
        await _flutterTts.speak(text);
      }
    } catch (_) {}
  }

  Future<void> stop() async {
    _generationTracker.reset();
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
