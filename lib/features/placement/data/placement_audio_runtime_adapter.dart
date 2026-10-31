import '../../../features/audio/domain/entities/audio_request.dart';
import '../../../features/audio/domain/services/i_audio_runtime.dart';
import '../domain/placement_models.dart';
import '../domain/placement_repositories.dart';

final class PlacementAudioRuntimeAdapter implements PlacementAudioGateway {
  const PlacementAudioRuntimeAdapter(this.runtime);

  final IAudioRuntime runtime;

  @override
  Future<bool> play(PlacementQuestion question) async {
    final text = question.audioText?.trim();
    if (text == null || text.isEmpty) return false;
    final result = await runtime.play(
      AudioRequest(
        text: text,
        languageCode: question.audioLanguageCode,
        conceptId: question.reviewItemId ?? question.id,
        variant: AudioVariant.sentence,
      ),
    );
    return result.played;
  }
}
