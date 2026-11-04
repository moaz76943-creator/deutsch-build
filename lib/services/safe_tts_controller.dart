import 'dart:async';

import '../core/infrastructure/audio/flutter_tts_audio_engine.dart';
import '../features/audio/domain/entities/audio_playback_result.dart';
import '../features/audio/domain/entities/audio_request.dart';
import '../features/audio/domain/services/i_audio_runtime.dart';
import '../features/audio/offline_audio_runtime.dart';
import '../language/german/german_speech_profile.dart';
import '../language/language_speech_profile.dart';

/// Compatibility API for existing UI consumers of the offline audio runtime.
class SafeTtsController {
  SafeTtsController({
    IAudioRuntime? runtime,
    LanguageSpeechProfile profile = const GermanSpeechProfile(),
  })  : _profile = profile,
        _runtime = runtime ??
            OfflineAudioRuntime(
              speechProfile: profile,
              ttsEngine: FlutterOfflineTtsEngine(),
            );

  final LanguageSpeechProfile _profile;
  final IAudioRuntime _runtime;
  AudioPlaybackResult? _lastResult;
  bool _disposed = false;
  bool _operationBusy = false;
  int _generation = 0;
  Future<void>? _shutdown;

  Future<void> speak(String text, {double rate = .46}) async {
    if (_disposed || text.trim().isEmpty) return;
    final generation = ++_generation;
    _operationBusy = true;
    try {
      final result = await _runtime.play(AudioRequest(
        text: text,
        languageCode: _profile.languageCode,
        rate: rate,
      ));
      if (!_disposed && generation == _generation) _lastResult = result;
    } finally {
      if (generation == _generation) _operationBusy = false;
    }
  }

  Future<void> stop() async {
    ++_generation;
    _operationBusy = false;
    if (!_disposed) await _runtime.stop();
  }

  Future<void> shutdown() {
    _disposed = true;
    ++_generation;
    _operationBusy = false;
    return _shutdown ??= _runtime.shutdown();
  }

  void dispose() {
    // Widgets cannot await dispose; explicit shutdown still exposes failures.
    unawaited(shutdown().catchError((Object error) {}));
  }

  bool get isDisposed => _disposed;
  bool get isBusy => _operationBusy;
  bool get isGermanVoiceReady =>
      _lastResult?.source == AudioPlaybackSource.offlineTts;
  String? get voiceError =>
      _lastResult?.source == AudioPlaybackSource.unavailable
          ? _profile.offlineVoiceUnavailableMessage
          : null;
}
