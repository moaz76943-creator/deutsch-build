import 'dart:async';

import '../../services/tts_service.dart';

/// Legacy singleton facade kept for caller compatibility.
///
/// It no longer owns a second FlutterTts engine. All speech is arbitrated by
/// TtsService's process-wide local engine authority.
class OfflineAudioPool {
  static final OfflineAudioPool _instance = OfflineAudioPool._internal();

  factory OfflineAudioPool() => _instance;

  OfflineAudioPool._internal() {
    _tts = TtsService(onStatus: _handleStatus);
  }

  late final TtsService _tts;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  void _handleStatus(
    TtsStatus status, {
    String? locale,
    String? message,
  }) {
    switch (status) {
      case TtsStatus.speaking:
        _isPlaying = true;
        break;
      case TtsStatus.completed:
      case TtsStatus.stopped:
      case TtsStatus.voiceMissing:
      case TtsStatus.unsupportedLanguage:
      case TtsStatus.unavailable:
      case TtsStatus.error:
        _isPlaying = false;
        break;
      case TtsStatus.idle:
      case TtsStatus.initializing:
      case TtsStatus.ready:
        break;
    }
  }

  Future<void> playWord(
    String text, {
    String locale = 'de-DE',
    double speechRate = 0.45,
  }) async {
    await tryPlayWord(
      text,
      locale: locale,
      speechRate: speechRate,
    );
  }

  /// Result-bearing companion for callers that need a real playback outcome.
  Future<bool> tryPlayWord(
    String text, {
    String locale = 'de-DE',
    double speechRate = 0.45,
  }) async {
    if (text.trim().isEmpty) return false;
    final configured = await _tts.configure(speechRate: speechRate);
    if (!configured) return false;
    return _tts.speak(text, languageCode: locale);
  }

  Future<void> stop() => _tts.stop();

  void dispose() {
    _isPlaying = false;
    unawaited(_tts.dispose());
  }
}
