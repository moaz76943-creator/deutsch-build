import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Offline Pronunciation Coach Service
/// Provides local speech recognition, TTS playback, and simple similarity scoring.
/// All processing is on-device for privacy and offline use. Compatible with existing speech_to_text and flutter_tts dependencies.
class PronunciationService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    final available = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    if (available) {
      await _tts.setLanguage('de-DE');
      await _tts.setSpeechRate(0.5);
      _isInitialized = true;
    }
    return available;
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    await _tts.speak(text);
  }

  Future<String?> listen({Duration timeout = const Duration(seconds: 5)}) async {
    if (!_isInitialized) await initialize();
    final completer = Completer<String?>();
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          completer.complete(result.recognizedWords);
        }
      },
      listenFor: timeout,
      localeId: 'de_DE',
    );
    return completer.future.timeout(timeout, onTimeout: () => null);
  }

  /// Simple offline scoring: Levenshtein distance based similarity (0.0 - 1.0)
  double scorePronunciation(String target, String spoken) {
    if (target.isEmpty || spoken.isEmpty) return 0.0;
    final distance = _levenshtein(target.toLowerCase(), spoken.toLowerCase());
    final maxLen = target.length > spoken.length ? target.length : spoken.length;
    return (1.0 - (distance / maxLen)).clamp(0.0, 1.0);
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);
    for (int i = 0; i < v0.length; i++) v0[i] = i;
    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        final cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }
      final tmp = v0;
      v0 = v1;
      v1 = tmp;
    }
    return v0[t.length];
  }

  void dispose() {
    _speech.stop();
    _tts.stop();
  }
}
