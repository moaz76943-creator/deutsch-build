import '../../../features/audio/domain/entities/audio_playback_result.dart';
import '../../../features/audio/domain/entities/audio_request.dart';
import '../../../features/audio/domain/services/i_audio_runtime.dart';
import 'speech_models.dart';

final class SpeechPracticeAudioPlayer {
  const SpeechPracticeAudioPlayer({required this.runtime});

  final IAudioRuntime runtime;

  Future<AudioPlaybackResult> play(
    SpeechPracticePrompt prompt, {
    double? rate,
  }) {
    if (!prompt.isValid) {
      return Future<AudioPlaybackResult>.value(
        const AudioPlaybackResult.unavailable('speech_practice_prompt_invalid'),
      );
    }

    return runtime.play(
      AudioRequest(
        text: prompt.text,
        languageCode: prompt.languageCode,
        conceptId: prompt.conceptId,
        variant: AudioVariant.pronunciation,
        rate: rate,
      ),
    );
  }

  Future<void> stop() => runtime.stop();
}
