import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../domain/entities/audio_playback_state.dart';
import '../domain/services/i_audio_service.dart';

class NativeTtsEngine implements IAudioService {
  final FlutterTts _flutterTts;
  final StreamController<AudioPlaybackState> _stateController =
      StreamController<AudioPlaybackState>.broadcast();
  bool _isDisposed = false;

  static final NativeTtsEngine _instance = NativeTtsEngine._internal();

  factory NativeTtsEngine() {
    return _instance;
  }

  NativeTtsEngine._internal({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts() {
    _initTts();
  }

  void _initTts() {
    _flutterTts.setStartHandler(() {
      _emitState(AudioPlaybackState.playing);
    });

    _flutterTts.setCompletionHandler(() {
      _emitState(AudioPlaybackState.completed);
      _emitState(AudioPlaybackState.idle);
    });

    _flutterTts.setErrorHandler((msg) {
      _emitState(AudioPlaybackState.error);
    });

    _flutterTts.setCancelHandler(() {
      _emitState(AudioPlaybackState.idle);
    });

    // Default configuration for German language
    _flutterTts.setLanguage("de-DE");
    _flutterTts.setSpeechRate(0.46);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  void _emitState(AudioPlaybackState state) {
    if (!_isDisposed && !_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  @override
  Stream<AudioPlaybackState> get playbackStateStream => _stateController.stream;

  @override
  Future<void> playVocabularyAudio({
    required String conceptId,
    required String languageCode,
  }) async {
    if (_isDisposed) return;

    // Note: A true implementation would look up the word by conceptId.
    // Given the parameters, this method is fundamentally difficult to satisfy offline
    // without a repository reference. We will keep it but UI will use `speak`
    _emitState(AudioPlaybackState.loading);
    String ttsLang = languageCode.toLowerCase().startsWith('de')
        ? 'de-DE'
        : languageCode;
    await _flutterTts.setLanguage(ttsLang);
    await _flutterTts.speak(conceptId);
  }

  Future<void> speak(String text, {String languageCode = 'de-DE'}) async {
    if (_isDisposed || text.trim().isEmpty) return;

    _emitState(AudioPlaybackState.loading);
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stop() async {
    if (_isDisposed) return;
    await _flutterTts.stop();
    _emitState(AudioPlaybackState.idle);
  }

  void dispose() {
    _isDisposed = true;
    _flutterTts.stop();
    _stateController.close();
  }
}
