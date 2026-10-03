import 'package:flutter_tts/flutter_tts.dart';

import '../features/audio/domain/entities/audio_playback_result.dart';
import '../features/audio/domain/entities/audio_request.dart';
import '../features/audio/domain/services/offline_tts_engine.dart';
import '../features/audio/offline_audio_runtime.dart';
import '../language/german/german_speech_profile.dart';
import '../language/language_speech_profile.dart';

final class FlutterOfflineTtsEngine implements OfflineTtsEngine {
  FlutterOfflineTtsEngine({FlutterTts? engine})
    : _engine = engine ?? FlutterTts();

  final FlutterTts _engine;
  Map<String, String>? _selectedVoice;
  String? _selectedLanguage;
  bool _closed = false;

  @override
  Future<OfflineTtsAvailability> probe(LanguageSpeechProfile profile) async {
    if (_closed) return OfflineTtsAvailability.unavailable;
    if (_selectedVoice != null && _selectedLanguage == profile.languageCode) {
      return OfflineTtsAvailability.ready;
    }
    try {
      final rawVoices = await _engine.getVoices;
      if (rawVoices is! List) return OfflineTtsAvailability.unavailable;
      final voice = selectOfflineVoice(rawVoices, profile.preferredTtsLocales);
      if (voice == null) return OfflineTtsAvailability.unavailable;

      final locale = voice['locale'];
      if (locale == null || locale.isEmpty) {
        return OfflineTtsAvailability.unavailable;
      }
      final installed = await _engine.isLanguageInstalled(locale);
      if (installed != true) {
        return OfflineTtsAvailability.unavailable;
      }

      _selectedVoice = voice;
      _selectedLanguage = profile.languageCode;
      return OfflineTtsAvailability.ready;
    } on Object {
      return OfflineTtsAvailability.unavailable;
    }
  }

  @override
  Future<bool> speak({
    required String text,
    required LanguageSpeechProfile profile,
    required double rate,
  }) async {
    if (_closed || text.trim().isEmpty) return false;
    if (await probe(profile) != OfflineTtsAvailability.ready) return false;
    final voice = _selectedVoice;
    if (voice == null) return false;
    try {
      await _engine.stop();
      await _engine.setVoice(voice);
      await _engine.setLanguage(voice['locale']!);
      await _engine.setSpeechRate(rate.clamp(.1, 1.0));
      await _engine.setPitch(1.0);
      await _engine.setVolume(1.0);
      await _engine.awaitSpeakCompletion(true);
      final result = await _engine.speak(text.trim());
      return result == 1 || result == true || result == null;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> stop() async {
    if (_closed) return;
    try {
      await _engine.stop();
    } on Object {
      // Platform failures remain inside the adapter boundary.
    }
  }

  @override
  Future<void> shutdown() async {
    if (_closed) return;
    _closed = true;
    try {
      await _engine.stop();
    } on Object {
      // Platform failures remain inside the adapter boundary.
    }
  }

  static Map<String, String>? selectOfflineVoice(
    List<dynamic> voices,
    List<String> preferredLocales,
  ) {
    final preferred = preferredLocales
        .map(_normalizeLocale)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    for (final locale in preferred) {
      for (final raw in voices) {
        if (raw is! Map) continue;
        final normalized = <String, String>{
          for (final entry in raw.entries)
            entry.key.toString(): entry.value.toString(),
        };
        final voiceLocale = _normalizeLocale(normalized['locale'] ?? '');
        if (voiceLocale != locale && !voiceLocale.startsWith(locale + '-')) {
          continue;
        }
        final networkRequired = (normalized['network_required'] ?? '')
            .trim()
            .toLowerCase();
        if (networkRequired == 'true' || networkRequired == '1') continue;
        final features = (normalized['features'] ?? '').toLowerCase();
        if (features.contains('notinstalled')) continue;
        final name = normalized['name']?.trim() ?? '';
        if (name.isEmpty) continue;
        return <String, String>{'name': name, 'locale': normalized['locale']!};
      }
    }
    return null;
  }

  static String _normalizeLocale(String value) =>
      value.trim().replaceAll('_', '-').toLowerCase();
}

/// Compatibility adapter. New code should receive IAudioRuntime from the
/// composition root rather than constructing TTS directly in widgets.
class SafeTtsController {
  SafeTtsController({
    OfflineAudioRuntime? runtime,
    LanguageSpeechProfile profile = const GermanSpeechProfile(),
  }) : _profile = profile,
       _runtime =
           runtime ??
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
  gate.tail = gate.tail
      .then<void>((_) => action(gate, generation))
      .catchError((_) {});
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
