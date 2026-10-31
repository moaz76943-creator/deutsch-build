import 'package:deutsch_bilarabi/core/audio/audio_session_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new audio focus replaces the previous active session', () {
    final coordinator = AudioSessionCoordinator();

    expect(coordinator.requestFocus('tts:1'), isTrue);
    expect(coordinator.activeAudioId, 'tts:1');
    expect(coordinator.state, AudioPlaybackState.playing);

    expect(coordinator.requestFocus('tts:2'), isTrue);
    expect(coordinator.activeAudioId, 'tts:2');
    expect(coordinator.state, AudioPlaybackState.playing);
  });

  test('stale owner cannot release newer audio focus', () {
    final coordinator = AudioSessionCoordinator()
      ..requestFocus('tts:old')
      ..requestFocus('tts:new');

    expect(coordinator.releaseFocus('tts:old'), isFalse);
    expect(coordinator.activeAudioId, 'tts:new');
    expect(coordinator.state, AudioPlaybackState.playing);

    expect(coordinator.releaseFocus('tts:new'), isTrue);
    expect(coordinator.activeAudioId, isNull);
    expect(coordinator.state, AudioPlaybackState.stopped);
  });
}
