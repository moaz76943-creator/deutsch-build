import 'package:flutter_tts/flutter_tts.dart';
import 'package:deutsch_bilarabi/core/audio/audio_generation_tracker.dart';

<<<<<<< HEAD
/// The platform TTS channel must not exist until an actual playback request.
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
class OfflineAudioManager {
  static final OfflineAudioManager instance = OfflineAudioManager._init();
  final FlutterTts _flutterTts = FlutterTts();
  final String _currentLocale = 'de-DE';

<<<<<<< HEAD
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

  Future<void> _ensureInitialized() => _initialization ??= _setupTts();

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
      if (_currentLocale != locale) {
        await tts.setLanguage(locale);
        _currentLocale = locale;
      }
      await tts.setSpeechRate(rate);
      await tts.speak(text);
    } catch (_) {
      // Missing on-device voices must not crash the review screen.
    }
  }

  Future<void> stop() async {
    final tts = _flutterTts;
    if (tts == null) return;
    try {
      await tts.stop();
=======
  OfflineAudioManager._init() {
    setupTts();
  }

  Future<void> setupTts() async {
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
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    } catch (_) {}
  }
}
