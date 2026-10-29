import '../../audio/domain/entities/audio_request.dart';
import '../../audio/domain/services/i_audio_runtime.dart';
import '../domain/story_audio_port.dart';

final class StoryAudioRuntimeAdapter implements StoryAudioPort {
  const StoryAudioRuntimeAdapter({
    required this.runtime,
    this.languageCode = 'de',
  });

  final IAudioRuntime runtime;
  final String languageCode;

  @override
  Future<bool> speak({
    required String text,
    required String conceptId,
  }) async {
    final value = text.trim();
    if (value.isEmpty) return false;
    final result = await runtime.play(
      AudioRequest(
        text: value,
        languageCode: languageCode,
        conceptId: conceptId,
        variant: AudioVariant.sentence,
      ),
    );
    return result.played;
  }
}
