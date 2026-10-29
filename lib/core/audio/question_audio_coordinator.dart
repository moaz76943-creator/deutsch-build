import 'dart:async';

/// Callback or player interface abstraction
abstract class AudioPlayerClient {
  Future<void> playAudioUri(String uri);
  Future<void> stop();
  Future<void> release();
}

/// QuestionAudioCoordinator guarantees Master Constitution Section 11:
/// Never play audio from a previous question after navigation or question switch.
/// Enforces generation-stamped playback and instant cancellation.
class QuestionAudioCoordinator {
  final AudioPlayerClient _playerClient;

  int _currentPlaybackGeneration = 0;
  String? _activeQuestionId;
  bool _isDisposed = false;

  QuestionAudioCoordinator(this._playerClient);

  String? get activeQuestionId => _activeQuestionId;
  int get currentGeneration => _currentPlaybackGeneration;

  /// Called when question changes in quiz, exercise, or flashcard review
  Future<void> transitionToQuestion(String newQuestionId) async {
    _currentPlaybackGeneration++;
    _activeQuestionId = newQuestionId;
    // Immediately halt any in-flight playback hardware
    await _playerClient.stop();
  }

  /// Requests playback for audio. Verified against active question and generation before playing.
  Future<bool> requestQuestionAudio({
    required String questionId,
    required Future<String> Function() audioUriResolver,
  }) async {
    if (_isDisposed) return false;

    final requestGen = ++_currentPlaybackGeneration;
    _activeQuestionId = questionId;

    try {
      // Asynchronous audio file retrieval / TTS synthesis probe
      final uri = await audioUriResolver();

      // Guard: Discard playback if question changed while audio was loading
      if (_isDisposed ||
          requestGen != _currentPlaybackGeneration ||
          _activeQuestionId != questionId) {
        return false;
      }

      await _playerClient.playAudioUri(uri);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Safe disposal of coordinator and underlying audio driver
  Future<void> dispose() async {
    _isDisposed = true;
    _currentPlaybackGeneration++;
    await _playerClient.stop();
    await _playerClient.release();
  }
}
