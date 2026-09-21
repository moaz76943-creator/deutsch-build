import 'package:flutter_tts/flutter_tts.dart';

/// Owns one TTS engine and makes rapid speak/stop/shutdown calls lifecycle-safe.
/// Generation invalidation prevents queued speech from starting after stop/dispose.
class SafeTtsController {
  final FlutterTts engine = FlutterTts();
  Future<void> _tail = Future<void>.value();
  bool _disposed = false;
  bool _operationBusy = false;
  int _generation = 0;
  bool? _germanVoiceReady;
  String? _voiceError;

  Future<void> speak(String text, {double rate = .46}) async {
    final value = text.trim();
    if (value.isEmpty || _disposed) return;
    final generation = ++_generation;
    await _enqueue(() async {
      if (_disposed || generation != _generation) return;
      _operationBusy = true;
      try {
        await engine.stop();
        if (_disposed || generation != _generation) return;
        if (!await _ensureGermanVoice()) return;
        if (_disposed || generation != _generation) return;
        await engine.setSpeechRate(rate.clamp(.1, 1.0));
        await engine.setPitch(1.0);
        await engine.setVolume(1.0);
        await engine.awaitSpeakCompletion(true);
        if (_disposed || generation != _generation) return;
        await engine.speak(value);
      } catch (_) {
        // TTS plugin failures must never escape into the UI.
      } finally {
        _operationBusy = false;
      }
    });
  }

  Future<void> stop() async {
    if (_disposed) return;
    ++_generation;
    try {
      await engine.stop();
    } catch (_) {}
    await _tail;
  }

  Future<void> shutdown() async {
    if (_disposed) return;
    _disposed = true;
    ++_generation;
    try {
      await engine.stop();
    } catch (_) {}
    await _tail;
    try {
      await engine.stop();
    } catch (_) {}
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    ++_generation;
    // Do not await from a synchronous Flutter dispose callback.
    Future<void>(() async {
      try { await engine.stop(); } catch (_) {}
      await _tail;
      try { await engine.stop(); } catch (_) {}
    });
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final next = _tail.then((_) => operation(), onError: (_) => operation());
    _tail = next.catchError((_) {});
    return next.catchError((_) {});
  }

  bool get isDisposed => _disposed;
  bool get isBusy => _operationBusy;
  bool get isGermanVoiceReady => _germanVoiceReady == true;
  String? get voiceError => _voiceError;

  Future<bool> _ensureGermanVoice() async {
    if (_germanVoiceReady == true) return true;
    if (_disposed) return false;
    try {
      final languages = await engine.getLanguages;
      final supported = languages
          .map((value) => value.toString().replaceAll('_', '-').toLowerCase())
          .where((value) => value.isNotEmpty)
          .toList();
      final locale = supported.contains('de-de')
          ? 'de-DE'
          : supported.firstWhere((value) => value == 'de' || value.startsWith('de-'), orElse: () => '');
      if (locale.isEmpty) {
        _voiceError = 'German TTS voice unavailable';
        _germanVoiceReady = false;
        return false;
      }

      final voices = await engine.getVoices;
      if (voices is List && voices.isNotEmpty) {
        dynamic germanVoice;
        for (final raw in voices) {
          if (raw is! Map) continue;
          final voiceLocale = raw['locale']?.toString().replaceAll('_', '-').toLowerCase() ?? '';
          if (voiceLocale == 'de-de' || voiceLocale == locale.toLowerCase()) {
            germanVoice = raw;
            break;
          }
        }
        if (germanVoice == null) {
          _voiceError = 'German TTS voice unavailable';
          _germanVoiceReady = false;
          return false;
        }
        await engine.setVoice(Map<String, String>.from(germanVoice.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        )));
      }
      await engine.setLanguage(locale);
      _voiceError = null;
      _germanVoiceReady = true;
      return true;
    } catch (_) {
      _voiceError = 'German TTS voice unavailable';
      _germanVoiceReady = false;
      return false;
    }
  }
}


/// Backward-compatible helpers use the same per-controller serialization gate.
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
  gate.tail = gate.tail.then<void>((_) => action(gate, generation)).catchError((_) {});
  return gate.tail;
}

Future<void> safeSpeak(SafeTtsController tts, String text, {double rate = .46}) async {
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
