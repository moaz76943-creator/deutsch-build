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
    this.resultPersisted = false,
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
  final bool resultPersisted;
  final bool isLoading;
  final bool isApplyingResult;
  final bool isPlayingAudio;
  final bool audioUnavailable;
  final String? errorMessage;

  double get progress => session?.progress ?? 0;
  bool get hasStarted => session != null;
  bool get canStartLearning =>
      result != null && resultPersisted && !isApplyingResult;
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

  static const String _startLoadError =
      'تعذر تجهيز أسئلة تحديد المستوى. أعد المحاولة.';
  static const String _nextQuestionLoadError =
      'تعذر تحميل السؤال التالي. أعد المحاولة دون فقدان إجاباتك.';
  static const String _answerStateError =
      'تعذر متابعة الاختبار بأمان. أعد المحاولة دون فقدان إجاباتك.';
  static const String _resultSaveError =
      'تعذر حفظ نتيجة الاختبار محلياً. أعد المحاولة قبل بدء التعلم.';
  static const String _audioError =
      'تعذر تشغيل الصوت حالياً؛ يمكنك متابعة الاختبار بدون صوت.';

  final PlacementRepository _repository;
  final PlacementProfileRepository _profileRepository;
  final PlacementAudioGateway _audioGateway;
  final AdaptivePlacementEngine _engine;
  final DateTime Function() _clock;

  PlacementTestState _state = const PlacementTestState();
  DateTime? _resultPersistenceTimestamp;
  bool _disposed = false;

  PlacementTestState get state => _state;

  void selectGoal(PlacementLearningGoal goal) {
    if (_disposed || _state.hasStarted || _state.isLoading) return;
    _setState(PlacementTestState(learningGoal: goal));
  }

  Future<void> start() async {
    if (_disposed ||
        _state.session != null ||
        _state.isLoading ||
        _state.isApplyingResult) {
      return;
    }
    final goal = _state.learningGoal ?? PlacementLearningGoal.general;
    _resultPersistenceTimestamp = null;
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
    } on Object {
      _setState(
        PlacementTestState(
          learningGoal: goal,
          errorMessage: _startLoadError,
        ),
      );
    }
  }

  Future<void> submitOption(String optionId) async {
    if (_disposed) return;
    final session = _state.session;
    final question = _state.currentQuestion;
    if (session == null ||
        question == null ||
        _state.isLoading ||
        _state.isApplyingResult ||
        _state.result != null) {
      return;
    }

    final goal = _state.learningGoal;
    _setState(
      PlacementTestState(
        session: session,
        currentQuestion: question,
        learningGoal: goal,
        lastAnswerCorrect: _state.lastAnswerCorrect,
        isLoading: true,
        audioUnavailable: _state.audioUnavailable,
      ),
    );

    late final AssessmentSession updated;
    try {
      updated = _engine.recordAnswer(
        session: session,
        question: question,
        selectedOptionId: optionId,
      );
    } on Object {
      _setState(
        PlacementTestState(
          session: session,
          learningGoal: goal,
          lastAnswerCorrect: _state.lastAnswerCorrect,
          errorMessage: _answerStateError,
        ),
      );
      return;
    }

    final lastAnswerCorrect = updated.answers.last.correct;
    if (updated.completed) {
      await _finish(
        updated,
        lastAnswerCorrect: lastAnswerCorrect,
      );
      return;
    }

    await _loadNextQuestion(
      updated,
      lastAnswerCorrect: lastAnswerCorrect,
    );
  }

  Future<void> retry() async {
    if (_disposed || _state.isLoading || _state.isApplyingResult) return;

    final result = _state.result;
    final session = _state.session;
    if (result != null && !_state.resultPersisted) {
      if (session == null) return;
      await _persistResult(
        session: session,
        result: result,
        lastAnswerCorrect: _state.lastAnswerCorrect ?? false,
      );
      return;
    }

    if (session == null) {
      await start();
      return;
    }

    if (_state.currentQuestion != null && _state.errorMessage == null) {
      return;
    }

    if (session.completed) {
      await _finish(
        session,
        lastAnswerCorrect: _state.lastAnswerCorrect ?? false,
      );
      return;
    }

    await _loadNextQuestion(
      session,
      lastAnswerCorrect: _state.lastAnswerCorrect,
    );
  }

  Future<bool> replayCurrentAudio() async {
    if (_disposed) return false;
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
        resultPersisted: _state.resultPersisted,
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
          resultPersisted: _state.resultPersisted,
          audioUnavailable: !played,
        ),
      );
      return played;
    } on Object {
      _setState(
        PlacementTestState(
          session: _state.session,
          currentQuestion: question,
          result: _state.result,
          learningGoal: _state.learningGoal,
          lastAnswerCorrect: _state.lastAnswerCorrect,
          resultPersisted: _state.resultPersisted,
          audioUnavailable: true,
          errorMessage: _audioError,
        ),
      );
      return false;
    }
  }

  Future<void> _loadNextQuestion(
    AssessmentSession session, {
    required bool? lastAnswerCorrect,
  }) async {
    final goal = _state.learningGoal;
    _setState(
      PlacementTestState(
        session: session,
        learningGoal: goal,
        lastAnswerCorrect: lastAnswerCorrect,
        isLoading: true,
      ),
    );

    try {
      final next = await _repository.nextQuestion(
        level: session.currentLevel,
        excludeIds: session.answeredQuestionIds,
      );
      if (next == null) {
        await _finish(
          session.copyWith(completed: true),
          lastAnswerCorrect: lastAnswerCorrect ?? false,
        );
        return;
      }

      _setState(
        PlacementTestState(
          session: session,
          currentQuestion: next,
          learningGoal: goal,
          lastAnswerCorrect: lastAnswerCorrect,
        ),
      );
    } on Object {
      _setState(
        PlacementTestState(
          session: session,
          learningGoal: goal,
          lastAnswerCorrect: lastAnswerCorrect,
          errorMessage: _nextQuestionLoadError,
        ),
      );
    }
  }

  Future<void> _finish(
    AssessmentSession session, {
    required bool lastAnswerCorrect,
  }) async {
    final completed =
        session.completed ? session : session.copyWith(completed: true);
    final goal = _state.learningGoal ?? PlacementLearningGoal.general;

    late final PlacementResult result;
    try {
      result = _engine.resultFor(completed).copyWith(
            learningGoal: goal,
          );
    } on Object {
      _setState(
        PlacementTestState(
          session: completed,
          learningGoal: goal,
          lastAnswerCorrect: lastAnswerCorrect,
          errorMessage: _answerStateError,
        ),
      );
      return;
    }

    await _persistResult(
      session: completed,
      result: result,
      lastAnswerCorrect: lastAnswerCorrect,
    );
  }

  Future<void> _persistResult({
    required AssessmentSession session,
    required PlacementResult result,
    required bool lastAnswerCorrect,
  }) async {
    final goal = result.learningGoal ??
        _state.learningGoal ??
        PlacementLearningGoal.general;
    _setState(
      PlacementTestState(
        session: session,
        result: result,
        learningGoal: goal,
        lastAnswerCorrect: lastAnswerCorrect,
        isApplyingResult: true,
      ),
    );

    final at = _resultPersistenceTimestamp ??= _clock();
    try {
      await _profileRepository.applyResult(result, at: at);
      _setState(
        PlacementTestState(
          session: session,
          result: result,
          learningGoal: goal,
          lastAnswerCorrect: lastAnswerCorrect,
          resultPersisted: true,
        ),
      );
    } on Object {
      _setState(
        PlacementTestState(
          session: session,
          result: result,
          learningGoal: goal,
          lastAnswerCorrect: lastAnswerCorrect,
          errorMessage: _resultSaveError,
        ),
      );
    }
  }

  void _setState(PlacementTestState value) {
    if (_disposed) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
