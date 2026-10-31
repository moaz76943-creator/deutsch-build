import 'domain/entities/audio_playback_result.dart';
import 'domain/entities/audio_request.dart';
import 'domain/services/i_audio_runtime.dart';

/// General pronunciation entrypoint for V1.1.
///
/// Source selection remains owned by [IAudioRuntime]: a verified local
/// recording is preferred when the catalog has one; otherwise the runtime may
/// use only its native offline TTS fallback.
final class HybridPronunciationService {
  const HybridPronunciationService({
    required IAudioRuntime audioRuntime,
  }) : _audioRuntime = audioRuntime;

  static const int maxConceptIdLength = 160;
  static const int maxTextLength = 2000;

  final IAudioRuntime _audioRuntime;

  Future<AudioPlaybackResult> play({
    required String conceptId,
    required String text,
    required String languageCode,
    bool slow = false,
  }) {
    final id = conceptId.trim();
    final spoken = text.trim();
    final language = languageCode.trim();
    if (id.isEmpty ||
        id.length > maxConceptIdLength ||
        spoken.isEmpty ||
        spoken.length > maxTextLength ||
        language.isEmpty) {
      return Future<AudioPlaybackResult>.value(
        const AudioPlaybackResult.unavailable(
          'pronunciation_request_invalid',
        ),
      );
    }

    return _audioRuntime.play(
      AudioRequest(
        text: spoken,
        languageCode: language,
        conceptId: id,
        variant: AudioVariant.pronunciation,
        rate: slow ? .34 : .48,
      ),
    );
  }
}
