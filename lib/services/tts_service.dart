import '../core/infrastructure/audio/flutter_tts_audio_engine.dart';
import '../features/audio/domain/entities/audio_playback_result.dart';
import '../features/audio/domain/entities/audio_request.dart';
import '../features/audio/offline_audio_runtime.dart';
import '../language/german/german_speech_profile.dart';
import '../language/language_speech_profile.dart';

export '../core/infrastructure/audio/flutter_tts_audio_engine.dart'
    show FlutterOfflineTtsEngine;

/// Compatibility adapter. New code should receive IAudioRuntime from the
/// composition root rather than constructing TTS directly in widgets.
class SafeTtsController {
  SafeTtsController({
    OfflineAudioRuntime? runtime,
    LanguageSpeechProfile profile = const GermanSpeechProfile(),
  })  : _profile = profile,
        _runtime = runtime ??
            OfflineAudioRuntime(
              speechProfile: profile,
              ttsEngine: FlutterOfflineTtsEngine(),
            );

  final LanguageSpeechProfile _profile;
  final OfflineAudioRuntime _runtime;
  AudioPlaybackResult? _lastResult;
  bool _disposed = false;
  bool _operationBusy = false;

  Future<void> speak(String text, {double rate = .46}) async {
    if (_disposed || text.trim().isEmpty) return;
    _operationBusy = true;
    try {
      _lastResult = await _runtime.play(
        AudioRequest(
          text: text,
          languageCode: _profile.languageCode,
          rate: rate,
        ),
      );
    } finally {
      _operationBusy = false;
    }
  }

  Future<void> stop() => _runtime.stop();

  Future<void> shutdown() async {
    if (_disposed) return;
    _disposed = true;
    await _runtime.shutdown();
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    Future<void>(() => _runtime.shutdown());
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

class _TtsGate {
  Future<void> tail = Future<void>.value();
  int generation = 0;
  bool closed = false;
}

final Expando<_TtsGate> _ttsGates = Expando<_TtsGate>('ttsGates');

_TtsGate _gateFor(SafeTtsController tts) => _ttsGates[tts] ??= _TtsGate();

Future<void> _enqueueTts(
  SafeTtsController tts,
  Future<void> Function(_TtsGate gate, int generation) action,
) {
  final gate = _gateFor(tts);
  final generation = gate.generation;
  gate.tail =
      gate.tail.then<void>((_) => action(gate, generation)).catchError((_) {});
  return gate.tail;
}

Future<void> safeSpeak(
  SafeTtsController tts,
  String text, {
  double rate = .46,
}) async {
  if (text.trim().isEmpty) return;
  final gate = _gateFor(tts);
  if (gate.closed) return;
  await _enqueueTts(tts, (gate, generation) async {
    if (gate.closed || generation != gate.generation) return;
    await tts.speak(text, rate: rate);
  });
}

Future<void> safeTtsStop(SafeTtsController tts) async {
  final gate = _gateFor(tts);
  gate.generation++;
  await _enqueueTts(tts, (gate, _) async {
    await tts.stop();
  });
}

Future<void> safeTtsShutdown(SafeTtsController tts) async {
  final gate = _gateFor(tts);
  gate.generation++;
  gate.closed = true;
  await gate.tail;
  await tts.shutdown();
}
