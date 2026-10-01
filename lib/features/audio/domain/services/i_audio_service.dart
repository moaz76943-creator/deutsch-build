import 'dart:async';

import '../entities/audio_playback_state.dart';

abstract class IAudioService {
  Future<void> playVocabularyAudio({
    required String conceptId,
    required String languageCode,
  });
  Future<void> stop();
  Stream<AudioPlaybackState> get playbackStateStream;
}
