import 'listening_models.dart';

enum AudioPlaybackVariant { listening, pronunciation }

final class AudioPlaybackRequest {
  const AudioPlaybackRequest({
    required this.text,
    required this.languageCode,
    required this.speedFactor,
    required this.variant,
    this.conceptId,
  }) : assert(speedFactor > 0 && speedFactor <= 1);

  final String text;
  final String languageCode;
  final double speedFactor;
  final AudioPlaybackVariant variant;
  final String? conceptId;
}

final class AudioRecordingResult {
  const AudioRecordingResult.available({
    this.recognizedText,
    this.recognizedPhonemes = const <String>[],
  })  : available = true,
        reason = null;

  const AudioRecordingResult.unavailable(this.reason)
      : available = false,
        recognizedText = null,
        recognizedPhonemes = const <String>[];

  final bool available;
  final String? recognizedText;
  final List<String> recognizedPhonemes;
  final String? reason;
}

abstract interface class AudioPlayerService {
  Future<bool> play(AudioPlaybackRequest request);

  Future<void> stop();
}

abstract interface class AudioRecorderService {
  Future<bool> requestPermission();

  Future<AudioRecordingResult> capturePronunciation({
    required String targetText,
    List<String> targetPhonemes = const <String>[],
  });
}

abstract interface class AudioPlayerFacade {
  Future<bool> playDrill(
    ListeningDrill drill, {
    ListeningPlaybackSpeed speed = ListeningPlaybackSpeed.normal,
  });

  Future<void> stop();
}
