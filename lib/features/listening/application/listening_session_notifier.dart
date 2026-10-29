import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/audio_services.dart';
import '../domain/listening_models.dart';
import 'pronunciation_matcher.dart';

class ListeningSessionNotifier extends ChangeNotifier {
  ListeningSessionNotifier({
    required List<ListeningDrill> drills,
    required AudioPlayerFacade player,
    required AudioRecorderService recorder,
  })  : _drills = List<ListeningDrill>.unmodifiable(drills),
        _player = player,
        _recorder = recorder {
    if (_drills.isEmpty) {
      throw ArgumentError('Listening session requires at least one drill.');
    }
  }

  final List<ListeningDrill> _drills;
  final AudioPlayerFacade _player;
  final AudioRecorderService _recorder;
  final Set<int> _answeredIndices = <int>{};

  int _index = 0;
  int _score = 0;
  bool _playing = false;
  bool _recording = false;
  ListeningAnswerResult? _lastAnswer;
  PronunciationFeedback? _pronunciationFeedback;

  ListeningDrill get currentDrill => _drills[_index];
  int get currentIndex => _index;
  int get totalDrills => _drills.length;
  int get score => _score;
  bool get isPlaying => _playing;
  bool get isRecording => _recording;
  bool get canAdvance => _answeredIndices.contains(_index);
  bool get isComplete => canAdvance && _index == _drills.length - 1;
  ListeningAnswerResult? get lastAnswer => _lastAnswer;
  PronunciationFeedback? get pronunciationFeedback => _pronunciationFeedback;

  Future<bool> playCurrent([
    ListeningPlaybackSpeed speed = ListeningPlaybackSpeed.normal,
  ]) async {
    if (_playing) return false;
    _playing = true;
    notifyListeners();
    try {
      return await _player.playDrill(currentDrill, speed: speed);
    } finally {
      _playing = false;
      notifyListeners();
    }
  }

  ListeningAnswerResult submitOption(String optionId) {
    _ensureUnanswered();
    final drill = currentDrill;
    if (drill.type != ListeningDrillType.multipleChoice) {
      throw StateError('Current listening drill is not multiple choice.');
    }

    ListeningOption? option;
    for (final candidate in drill.options) {
      if (candidate.id == optionId) {
        option = candidate;
        break;
      }
    }
    if (option == null) {
      throw ArgumentError.value(optionId, 'optionId', 'Unknown option.');
    }

    return _recordAnswer(
      answer: option.id,
      expected: drill.correctOptionId!,
      correct: option.id == drill.correctOptionId,
    );
  }

  ListeningAnswerResult submitDictation(String answer) {
    _ensureUnanswered();
    final drill = currentDrill;
    if (drill.type != ListeningDrillType.dictation) {
      throw StateError('Current listening drill is not dictation.');
    }
    final expected = _normalizeAnswer(drill.expectedText!);
    final normalized = _normalizeAnswer(answer);
    return _recordAnswer(
      answer: normalized,
      expected: expected,
      correct: normalized.isNotEmpty && normalized == expected,
    );
  }

  void next() {
    if (!canAdvance) {
      throw StateError('Answer the current listening drill before advancing.');
    }
    if (_index >= _drills.length - 1) return;
    _index += 1;
    _lastAnswer = null;
    _pronunciationFeedback = null;
    notifyListeners();
  }

  Future<PronunciationFeedback> evaluatePronunciation() async {
    if (_recording) {
      throw StateError('Pronunciation capture is already running.');
    }
    _recording = true;
    notifyListeners();
    try {
      final allowed = await _recorder.requestPermission();
      final recording = allowed
          ? await _recorder.capturePronunciation(
              targetText: currentDrill.audioText,
              targetPhonemes: currentDrill.targetPhonemes,
            )
          : const AudioRecordingResult.unavailable(
              'microphone_permission_required',
            );
      final feedback = PronunciationMatcher.evaluate(
        recording: recording,
        targetText: currentDrill.audioText,
        targetPhonemes: currentDrill.targetPhonemes,
      );
      _pronunciationFeedback = feedback;
      return feedback;
    } finally {
      _recording = false;
      notifyListeners();
    }
  }

  ListeningAnswerResult _recordAnswer({
    required String answer,
    required String expected,
    required bool correct,
  }) {
    _answeredIndices.add(_index);
    final result = ListeningAnswerResult(
      correct: correct,
      pointsAwarded: correct ? 10 : 0,
      normalizedExpected: expected,
      normalizedAnswer: answer,
    );
    _score += result.pointsAwarded;
    _lastAnswer = result;
    notifyListeners();
    return result;
  }

  void _ensureUnanswered() {
    if (_answeredIndices.contains(_index)) {
      throw StateError('Current listening drill has already been answered.');
    }
  }

  static String _normalizeAnswer(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[.,!?;:„“"…]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  void dispose() {
    unawaited(_player.stop());
    super.dispose();
  }
}
