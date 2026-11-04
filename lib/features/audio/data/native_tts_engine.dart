import 'dart:async';

import '../../../language/german/german_speech_profile.dart';
import '../../../core/infrastructure/audio/flutter_tts_audio_engine.dart';
import '../domain/entities/audio_playback_state.dart';
import '../domain/entities/audio_request.dart';
import '../domain/services/i_audio_service.dart';
import '../offline_audio_runtime.dart';

/// Compatibility adapter for the early audio feature surface.
///
/// It now delegates to the unified offline runtime and never speaks a
/// conceptId as though it were learner-facing text.
class NativeTtsEngine implements IAudioService {
  NativeTtsEngine({OfflineAudioRuntime? runtime})
      : _runtime = runtime ??
            OfflineAudioRuntime(
              speechProfile: const GermanSpeechProfile(),
              ttsEngine: FlutterOfflineTtsEngine(),
            );

  final OfflineAudioRuntime _runtime;

  @override
  Stream<AudioPlaybackState> get playbackStateStream =>
      _runtime.playbackStateStream;

  @override
  Future<void> playVocabularyAudio({
    required String conceptId,
    required String languageCode,
  }) async {
    // This legacy signature does not contain learner-facing text. Fail closed
    // instead of pronouncing the technical concept identifier.
  }

  Future<void> speak(
    String text, {
    String languageCode = 'de',
    String? conceptId,
  }) async {
    await _runtime.play(
      AudioRequest(
        text: text,
        languageCode: languageCode,
        conceptId: conceptId,
      ),
    );
  }

  @override
  Future<void> stop() => _runtime.stop();

  void dispose() {
    Future<void>(() => _runtime.shutdown());
  }
}
