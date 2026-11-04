import 'dart:async';

import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_result.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_state.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_request.dart';
import 'package:deutsch_bilarabi/features/audio/domain/services/i_audio_runtime.dart';
import 'package:deutsch_bilarabi/language/arabic/arabic_speech_profile.dart';
import 'package:deutsch_bilarabi/ui_v35/safe_ui.dart';
import 'package:flutter_test/flutter_test.dart';

class ControlledRuntime implements IAudioRuntime {
  final requests = <AudioRequest>[];
  final completions = <Completer<AudioPlaybackResult>>[];
  int stops = 0;
  int shutdowns = 0;
  @override
  Stream<AudioPlaybackState> get playbackStateStream => const Stream.empty();
  @override
  Future<AudioPlaybackResult> play(AudioRequest request) {
    requests.add(request);
    final completion = Completer<AudioPlaybackResult>();
    completions.add(completion);
    return completion.future;
  }

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> shutdown() async {
    shutdowns++;
  }
}

void main() {
  test('compatibility UI API preserves text, explicit language and rate',
      () async {
    final runtime = ControlledRuntime();
    final controller = SafeTtsController(
        runtime: runtime, profile: const ArabicSpeechProfile());
    final speech = controller.speak('مرحبا', rate: .3);
    expect(runtime.requests.single.text, 'مرحبا');
    expect(runtime.requests.single.languageCode, 'ar');
    expect(runtime.requests.single.rate, .3);
    runtime.completions.single.complete(const AudioPlaybackResult.offlineTts());
    await speech;
    expect(controller.isBusy, isFalse);
    await controller.shutdown();
  });

  test('late old result cannot replace missing-voice state of latest request',
      () async {
    final runtime = ControlledRuntime();
    final controller = SafeTtsController(runtime: runtime);
    final old = controller.speak('old');
    final current = controller.speak('current');
    runtime.completions[1]
        .complete(const AudioPlaybackResult.unavailable('missing'));
    await current;
    runtime.completions[0].complete(const AudioPlaybackResult.offlineTts());
    await old;
    expect(controller.isGermanVoiceReady, isFalse);
    expect(controller.voiceError, isNotNull);
    expect(controller.isBusy, isFalse);
    await controller.shutdown();
  });

  test('stop invalidates pending status and shutdown is idempotent', () async {
    final runtime = ControlledRuntime();
    final controller = SafeTtsController(runtime: runtime);
    final pending = controller.speak('pending');
    await controller.stop();
    runtime.completions.single.complete(const AudioPlaybackResult.offlineTts());
    await pending;
    expect(controller.isGermanVoiceReady, isFalse);
    expect(controller.isBusy, isFalse);
    expect(runtime.stops, 1);
    await controller.shutdown();
    await controller.shutdown();
    await controller.speak('after shutdown');
    expect(runtime.shutdowns, 1);
    expect(runtime.requests, hasLength(1));
  });
}
