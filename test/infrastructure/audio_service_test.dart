import 'dart:async';

import 'package:deutsch_bilarabi/core/infrastructure/audio/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeGermanAudioEngine implements GermanAudioEngine {
  bool holdSpeech = false;
  bool failSpeech = false;
  int pauseCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;
  Completer<void>? _speech;

  @override
  Future<void> speakGerman(String text, {required double rate}) async {
    if (failSpeech) throw StateError('tts_failed');
    if (!holdSpeech) return;
    _speech = Completer<void>();
    await _speech!.future;
  }

  void completeSpeech() => _speech?.complete();

  @override
  Future<void> pause() async {
    pauseCalls++;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }
}

void main() {
  test('speech emits playing then returns to idle', () async {
    final engine = _FakeGermanAudioEngine();
    final service = ManagedAudioService(engine);
    final states = <AudioServiceState>[];
    final subscription = service.states.listen(states.add);

    await service.speakGerman('Haus');

    expect(states, <AudioServiceState>[
      AudioServiceState.playing,
      AudioServiceState.idle,
    ]);
    expect(service.state, AudioServiceState.idle);

    await subscription.cancel();
    await service.dispose();
  });

  test('pause owns paused state until stop resets to idle', () async {
    final engine = _FakeGermanAudioEngine()..holdSpeech = true;
    final service = ManagedAudioService(engine);
    final speech = service.speakGerman('gehen');
    await Future<void>.delayed(Duration.zero);

    await service.pause();

    expect(engine.pauseCalls, 1);
    expect(service.state, AudioServiceState.paused);

    engine.completeSpeech();
    await speech;
    expect(service.state, AudioServiceState.paused);

    await service.stop();
    expect(engine.stopCalls, 1);
    expect(service.state, AudioServiceState.idle);

    await service.dispose();
  });

  test('backend failures transition to error and expose a typed failure',
      () async {
    final engine = _FakeGermanAudioEngine()..failSpeech = true;
    final service = ManagedAudioService(engine);

    await expectLater(
      service.speakGerman('Haus'),
      throwsA(
        isA<AudioServiceFailure>().having(
          (failure) => failure.code,
          'code',
          AudioServiceFailureCode.playbackFailed,
        ),
      ),
    );
    expect(service.state, AudioServiceState.error);

    await service.dispose();
  });

  test('dispose closes the engine exactly once', () async {
    final engine = _FakeGermanAudioEngine();
    final service = ManagedAudioService(engine);

    await service.dispose();
    await service.dispose();

    expect(engine.disposeCalls, 1);
  });
}
