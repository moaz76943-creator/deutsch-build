import '../entities/audio_playback_result.dart';
import '../entities/audio_playback_state.dart';
import '../entities/audio_request.dart';

abstract interface class IAudioRuntime {
  Stream<AudioPlaybackState> get playbackStateStream;

  Future<AudioPlaybackResult> play(AudioRequest request);

  Future<void> stop();

  Future<void> shutdown();
}

final class UnavailableAudioRuntime implements IAudioRuntime {
  const UnavailableAudioRuntime();

  @override
  Stream<AudioPlaybackState> get playbackStateStream =>
      Stream<AudioPlaybackState>.empty();

  @override
  Future<AudioPlaybackResult> play(AudioRequest request) async =>
      const AudioPlaybackResult.unavailable('audio_runtime_unavailable');

  @override
  Future<void> stop() async {}

  @override
  Future<void> shutdown() async {}
}
