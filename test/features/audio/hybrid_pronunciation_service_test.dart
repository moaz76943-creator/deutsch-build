import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_result.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_state.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_request.dart';
import 'package:deutsch_bilarabi/features/audio/domain/services/i_audio_runtime.dart';
import 'package:deutsch_bilarabi/features/audio/hybrid_pronunciation_service.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Runtime implements IAudioRuntime {
  AudioRequest? lastRequest;
  AudioPlaybackResult result = const AudioPlaybackResult.offlineTts();

  @override
  Stream<AudioPlaybackState> get playbackStateStream =>
      const Stream<AudioPlaybackState>.empty();

  @override
  Future<AudioPlaybackResult> play(AudioRequest request) async {
    lastRequest = request;
    return result;
  }

  @override
  Future<void> shutdown() async {}

  @override
  Future<void> stop() async {}
}

void main() {
  test('pronunciation delegates to hybrid runtime with pronunciation variant',
      () async {
    final runtime = _Runtime();
    final service = HybridPronunciationService(
      audioRuntime: runtime,
    );

    final result = await service.play(
      conceptId: 'noun.haus',
      text: 'Haus',
      languageCode: 'de-DE',
    );

    expect(result.source, AudioPlaybackSource.offlineTts);
    expect(runtime.lastRequest?.conceptId, 'noun.haus');
    expect(runtime.lastRequest?.text, 'Haus');
    expect(runtime.lastRequest?.languageCode, 'de-DE');
    expect(runtime.lastRequest?.variant, AudioVariant.pronunciation);
    expect(runtime.lastRequest?.rate, .48);
  });

  test('slow pronunciation stays bounded and uses the same offline runtime',
      () async {
    final runtime = _Runtime();
    runtime.result = const AudioPlaybackResult.recorded();
    final service = HybridPronunciationService(
      audioRuntime: runtime,
    );

    final result = await service.play(
      conceptId: 'verb.lernen',
      text: 'lernen',
      languageCode: 'de',
      slow: true,
    );

    expect(result.source, AudioPlaybackSource.recorded);
    expect(runtime.lastRequest?.variant, AudioVariant.pronunciation);
    expect(runtime.lastRequest?.rate, .34);
  });

  test('invalid pronunciation request fails without touching runtime',
      () async {
    final runtime = _Runtime();
    final service = HybridPronunciationService(
      audioRuntime: runtime,
    );

    final result = await service.play(
      conceptId: '',
      text: '',
      languageCode: 'de',
    );

    expect(result.source, AudioPlaybackSource.unavailable);
    expect(result.reason, 'pronunciation_request_invalid');
    expect(runtime.lastRequest, isNull);
  });
}
