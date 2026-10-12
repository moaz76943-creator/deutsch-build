import 'dart:async';

import '../../services/tts_service.dart';

/// Legacy singleton facade kept for caller compatibility.
///
/// It no longer owns a second FlutterTts engine. All speech is arbitrated by
/// TtsService's process-wide local engine authority.
class OfflineAudioPool {
  static final OfflineAudioPool _instance = OfflineAudioPool._internal();

  factory OfflineAudioPool() => _instance;

  OfflineAudioPool._internal();

  TtsService? _tts;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  TtsService get _service =>
      _tts ??= TtsService(onStatus: _handleStatus);

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
    final service = _service;
    final configured = await service.configure(speechRate: speechRate);
    if (!configured) return false;
    return service.speak(text, languageCode: locale);
  }

  Future<void> stop() async {
    final service = _tts;
    if (service == null) return;
    await service.stop();
  }

  void dispose() {
    _isPlaying = false;
    final service = _tts;
    _tts = null;
    if (service != null) unawaited(service.dispose());
  }
}
