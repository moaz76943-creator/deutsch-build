import '../../../features/audio/domain/entities/audio_playback_result.dart';
import '../../../features/audio/domain/services/i_audio_runtime.dart';
import 'audio_asset_player.dart';
import 'speech_models.dart';
import 'voice_recognition_engine.dart';

final class SpeechPracticeHub {
  SpeechPracticeHub({
    required IAudioRuntime audioRuntime,
    VoiceRecognitionEngine recognitionEngine =
        const VoiceRecognitionEngine(),
  })  : _audioPlayer = SpeechPracticeAudioPlayer(runtime: audioRuntime),
        _recognitionEngine = recognitionEngine;

  final SpeechPracticeAudioPlayer _audioPlayer;
  final VoiceRecognitionEngine _recognitionEngine;

  Future<AudioPlaybackResult> play(
    SpeechPracticePrompt prompt, {
    double? rate,
  }) =>
      _audioPlayer.play(prompt, rate: rate);

  Future<void> stopAudio() => _audioPlayer.stop();

  SpeechComparison evaluateTranscript({
    required SpeechPracticePrompt prompt,
    required String recognizedText,
  }) =>
      _recognitionEngine.compare(
        prompt: prompt,
        recognizedText: recognizedText,
      );

  SpeechRecognitionSession createRecognitionSession(
    SpeechPracticePrompt prompt,
  ) {
    if (!prompt.isValid) {
      throw ArgumentError('speech practice prompt must be complete');
    }
    return _recognitionEngine.createSession(prompt);
  }
}
