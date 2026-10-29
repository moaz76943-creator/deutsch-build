import '../../audio/domain/entities/audio_request.dart' as core_audio;
import '../../audio/domain/services/i_audio_runtime.dart';
import '../../pronunciation/domain/services/pronunciation_signal_probe.dart';
import '../domain/audio_services.dart';

final class RuntimeAudioPlayerService implements AudioPlayerService {
  const RuntimeAudioPlayerService(this._runtime);

  final IAudioRuntime _runtime;

  @override
  Future<bool> play(AudioPlaybackRequest request) async {
    if (request.text.trim().isEmpty) return false;
    final result = await _runtime.play(
      core_audio.AudioRequest(
        text: request.text,
        languageCode: request.languageCode,
        conceptId: request.conceptId,
        variant: request.variant == AudioPlaybackVariant.pronunciation
            ? core_audio.AudioVariant.pronunciation
            : core_audio.AudioVariant.sentence,
        rate: request.speedFactor <= .8 ? .38 : null,
      ),
    );
    return result.played;
  }

  @override
  Future<void> stop() => _runtime.stop();
}

final class SignalAudioRecorderService implements AudioRecorderService {
  const SignalAudioRecorderService(this._probe);

  final PronunciationSignalProbe _probe;

  @override
  Future<bool> requestPermission() => _probe.requestPermission();

  @override
  Future<AudioRecordingResult> capturePronunciation({
    required String targetText,
    List<String> targetPhonemes = const <String>[],
  }) async {
    final capture = await _probe.capture(
      maxDuration: const Duration(milliseconds: 1800),
    );
    if (!capture.available) {
      return AudioRecordingResult.unavailable(
        capture.reason ?? 'pronunciation_capture_unavailable',
      );
    }
    return const AudioRecordingResult.available();
  }
}
