import 'package:flutter_tts/flutter_tts.dart';
import 'package:deutsch_bilarabi/core/audio/audio_generation_tracker.dart';

/// The platform TTS channel must not exist until an actual playback request.
class OfflineAudioManager {
  static final OfflineAudioManager instance = OfflineAudioManager._init();

  OfflineAudioManager._init() : _createTts = FlutterTts.new;

  /// Provides a deterministic lazy factory for focused unit tests.
  OfflineAudioManager.forTesting({
    required FlutterTts Function() createTts,
  }) : _createTts = createTts;

  final FlutterTts Function() _createTts;
  FlutterTts? _flutterTts;
  Future<void>? _initialization;
  String _currentLocale = 'de-DE';
  final AudioGenerationTracker _generationTracker = AudioGenerationTracker();

  bool get isAudioInitialized => _flutterTts != null;

  Future<void> _ensureInitialized() =>
      _initialization ??= _setupTts();

  Future<void> _setupTts() async {
    final tts = _flutterTts ??= _createTts();
    try {
      await tts.setLanguage('de-DE');
      await tts.setSpeechRate(0.4);
      await tts.setVolume(1.0);
    } catch (_) {
      _initialization = null; // Retry configuration on the next play request.
      rethrow;
    }
  }

<<<<<<< HEAD
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

=======
  Future<void> speak(
    String text, {
    String locale = 'de-DE',
    double rate = 0.4,
  }) async {
    if (text.trim().isEmpty) return;
    try {
      await _ensureInitialized();
      final tts = _flutterTts!;
      await tts.stop();
>>>>>>> pr-179
      if (_currentLocale != locale) {
        await tts.setLanguage(locale);
        _currentLocale = locale;
      }
<<<<<<< HEAD
      await _flutterTts.setSpeechRate(rate);

      if (_generationTracker.isCurrent(currentGen)) {
        await _flutterTts.speak(text);
      }
    } catch (_) {}
  }

  Future<void> stop() async {
    _generationTracker.reset();
=======
      await tts.setSpeechRate(rate);
      await tts.speak(text);
    } catch (_) {
      // Missing on-device voices must not crash the review screen.
    }
  }

  Future<void> stop() async {
    final tts = _flutterTts;
    if (tts == null) return;
>>>>>>> pr-179
    try {
      await tts.stop();
    } catch (_) {}
  }
}
