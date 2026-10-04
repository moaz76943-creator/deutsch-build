import 'package:flutter/foundation.dart';

import '../domain/adaptive_placement_engine.dart';
import '../domain/placement_models.dart';
import '../domain/placement_repositories.dart';

final class PlacementTestState {
  const PlacementTestState({
    this.session,
    this.currentQuestion,
    this.result,
    this.learningGoal,
    this.lastAnswerCorrect,
    this.isLoading = false,
    this.isApplyingResult = false,
    this.isPlayingAudio = false,
    this.audioUnavailable = false,
    this.errorMessage,
  });

  final AssessmentSession? session;
  final PlacementQuestion? currentQuestion;
  final PlacementResult? result;
  final PlacementLearningGoal? learningGoal;
  final bool? lastAnswerCorrect;
  final bool isLoading;
  final bool isApplyingResult;
  final bool isPlayingAudio;
  final bool audioUnavailable;
  final String? errorMessage;

  double get progress => session?.progress ?? 0;
  bool get hasStarted => session != null;
}

class PlacementTestNotifier extends ChangeNotifier {
  PlacementTestNotifier({
    required PlacementRepository repository,
    required PlacementProfileRepository profileRepository,
    PlacementAudioGateway audioGateway =
        const UnavailablePlacementAudioGateway(),
    AdaptivePlacementEngine engine = const AdaptivePlacementEngine(),
    DateTime Function()? clock,
  })  : _repository = repository,
        _profileRepository = profileRepository,
        _audioGateway = audioGateway,
        _engine = engine,
        _clock = clock ?? DateTime.now;

  final PlacementRepository _repository;
  final PlacementProfileRepository _profileRepository;
  final PlacementAudioGateway _audioGateway;
  final AdaptivePlacementEngine _engine;
  final DateTime Function() _clock;

  PlacementTestState _state = const PlacementTestState();

  PlacementTestState get state => _state;

  void selectGoal(PlacementLearningGoal goal) {
    if (_state.hasStarted || _state.isLoading) return;
    _setState(PlacementTestState(learningGoal: goal));
  }

  Future<void> start() async {
    if (_state.session != null || _state.isLoading) return;
    final goal = _state.learningGoal ?? PlacementLearningGoal.general;
    _setState(
      PlacementTestState(
        learningGoal: goal,
        isLoading: true,
      ),
    );

    try {
      final now = _clock();
      final session = _engine.start(
        sessionId: 'placement_${now.microsecondsSinceEpoch}',
        now: now,
      );
      final question = await _repository.nextQuestion(
        level: session.currentLevel,
        excludeIds: const <String>{},
      );
      if (question == null) {
        _setState(
          PlacementTestState(
            learningGoal: goal,
            errorMessage: 'لا توجد أسئلة تشخيصية متاحة حالياً.',
          ),
        );
        return;
      }
      _setState(
        PlacementTestState(
          session: session,
          currentQuestion: question,
          learningGoal: goal,
        ),
      );
    } catch (error) {
      _setState(
        PlacementTestState(
          learningGoal: goal,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> submitOption(String optionId) async {
    final session = _state.session;
    final question = _state.currentQuestion;
    if (session == null ||
        question == null ||
        _state.isLoading ||
        _state.isApplyingResult) {
      return;
    }

    final updated = _engine.recordAnswer(
      session: session,
      question: question,
      selectedOptionId: optionId,
    );
    final lastAnswerCorrect = updated.answers.last.correct;

    if (updated.completed) {
      await _finish(
        updated,
        lastAnswerCorrect: lastAnswerCorrect,
      );
      return;
    }

    _setState(
      PlacementTestState(
        session: updated,
        currentQuestion: question,
        learningGoal: _state.learningGoal,
        lastAnswerCorrect: lastAnswerCorrect,
        isLoading: true,
      ),
    );

    try {
      final next = await _repository.nextQuestion(
        level: updated.currentLevel,
        excludeIds: updated.answeredQuestionIds,
      );
      if (next == null) {
        await _finish(
          updated.copyWith(completed: true),
          lastAnswerCorrect: lastAnswerCorrect,
        );
        return;
      }

      _setState(
        PlacementTestState(
          session: updated,
          currentQuestion: next,
          learningGoal: _state.learningGoal,
          lastAnswerCorrect: lastAnswerCorrect,
        ),
      );
    } catch (error) {
      _setState(
        PlacementTestState(
          session: updated,
          currentQuestion: question,
          learningGoal: _state.learningGoal,
          lastAnswerCorrect: lastAnswerCorrect,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<bool> replayCurrentAudio() async {
    final question = _state.currentQuestion;
    if (question == null || !question.hasAudio || _state.isPlayingAudio) {
      return false;
    }

    _setState(
      PlacementTestState(
        session: _state.session,
        currentQuestion: question,
        result: _state.result,
        learningGoal: _state.learningGoal,
        lastAnswerCorrect: _state.lastAnswerCorrect,
        isPlayingAudio: true,
      ),
    );

    try {
      final played = await _audioGateway.play(question);
      _setState(
        PlacementTestState(
          session: _state.session,
          currentQuestion: question,
          result: _state.result,
          learningGoal: _state.learningGoal,
          lastAnswerCorrect: _state.lastAnswerCorrect,
          audioUnavailable: !played,
        ),
      );
      return played;
    } catch (error) {
      _setState(
        PlacementTestState(
          session: _state.session,
          currentQuestion: question,
          result: _state.result,
          learningGoal: _state.learningGoal,
          lastAnswerCorrect: _state.lastAnswerCorrect,
          audioUnavailable: true,
          errorMessage: error.toString(),
        ),
      );
      return false;
    }
  }

  Future<void> _finish(
    AssessmentSession session, {
    required bool lastAnswerCorrect,
  }) async {
    final completed =
        session.completed ? session : session.copyWith(completed: true);
    final goal = _state.learningGoal ?? PlacementLearningGoal.general;
    final result = _engine.resultFor(completed).copyWith(
          learningGoal: goal,
        );
    _setState(
      PlacementTestState(
        session: completed,
        result: result,
        learningGoal: goal,
        lastAnswerCorrect: lastAnswerCorrect,
        isApplyingResult: true,
      ),
    );

    try {
      await _profileRepository.applyResult(result, at: _clock());
      _setState(
        PlacementTestState(
          session: completed,
          result: result,
          learningGoal: goal,
          lastAnswerCorrect: lastAnswerCorrect,
        ),
      );
    } catch (error) {
      _setState(
        PlacementTestState(
          session: completed,
          result: result,
          learningGoal: goal,
          lastAnswerCorrect: lastAnswerCorrect,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _setState(PlacementTestState value) {
    _state = value;
    notifyListeners();
  }
}
