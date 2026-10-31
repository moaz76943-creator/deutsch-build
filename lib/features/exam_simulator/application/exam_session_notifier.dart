import 'dart:async';

import '../domain/exam_models.dart';
import '../domain/exam_repository.dart';
import '../domain/exam_scoring_engine.dart';

final class ExamSessionState {
  const ExamSessionState({
    required this.exam,
    required this.session,
    required this.remainingSeconds,
    this.report,
  });

  final ExamDefinition exam;
  final ExamSession session;
  final int remainingSeconds;
  final ExamScoreReport? report;

  ExamQuestion get currentQuestion =>
      exam.questions[session.currentQuestionIndex];

  int get answeredCount => session.answers.length;

  double get progress =>
      ((session.currentQuestionIndex + 1) / exam.questions.length)
          .clamp(0.0, 1.0)
          .toDouble();

  bool get isFinished => session.isFinished;
}

final class ExamSessionNotifier {
  ExamSessionNotifier(this._repository);

  final ExamRepository _repository;
  final StreamController<ExamSessionState> _changes =
      StreamController<ExamSessionState>.broadcast();

  ExamSessionState? _state;
  Timer? _timer;
  bool _disposed = false;

  ExamSessionState get state {
    final value = _state;
    if (value == null) {
      throw StateError('Exam session has not started');
    }
    return value;
  }

  Stream<ExamSessionState> get changes => _changes.stream;

  Future<ExamSessionState> start({
    required CefrExamLevel level,
    required DateTime startedAtUtc,
  }) async {
    _ensureActive();
    if (!startedAtUtc.isUtc) {
      throw ArgumentError('startedAtUtc must be UTC');
    }

    final exam = await _repository.loadExam(level);
    final session = ExamSession(
      examId: exam.id,
      startedAtUtc: startedAtUtc,
      durationSeconds: exam.duration.inSeconds,
      currentQuestionIndex: 0,
      answers: const <String, int>{},
    );
    _emit(
      ExamSessionState(
        exam: exam,
        session: session,
        remainingSeconds: exam.duration.inSeconds,
      ),
    );
    _startTimer();
    return state;
  }

  bool answerCurrent(int optionIndex) {
    final current = state;
    if (current.isFinished) return false;

    final question = current.currentQuestion;
    if (optionIndex < 0 || optionIndex >= question.options.length) {
      return false;
    }

    final answers = Map<String, int>.from(current.session.answers);
    answers[question.id] = optionIndex;
    _emit(
      ExamSessionState(
        exam: current.exam,
        session: current.session.copyWith(answers: answers),
        remainingSeconds: current.remainingSeconds,
        report: current.report,
      ),
    );
    return true;
  }

  bool goNext() {
    final current = state;
    if (current.isFinished) return false;
    final next = current.session.currentQuestionIndex + 1;
    if (next >= current.exam.questions.length) return false;
    _moveTo(next);
    return true;
  }

  bool goPrevious() {
    final current = state;
    if (current.isFinished) return false;
    final previous = current.session.currentQuestionIndex - 1;
    if (previous < 0) return false;
    _moveTo(previous);
    return true;
  }

  bool goToQuestion(int index) {
    final current = state;
    if (current.isFinished) return false;
    if (index < 0 || index >= current.exam.questions.length) return false;
    _moveTo(index);
    return true;
  }

  void synchronize(DateTime nowUtc) {
    final current = state;
    if (current.isFinished) return;
    if (!nowUtc.isUtc) {
      throw ArgumentError('nowUtc must be UTC');
    }

    final remaining = current.session.remainingSeconds(nowUtc);
    if (remaining <= 0) {
      _finish(nowUtc, timedOut: true);
      return;
    }
    if (remaining != current.remainingSeconds) {
      _emit(
        ExamSessionState(
          exam: current.exam,
          session: current.session,
          remainingSeconds: remaining,
          report: current.report,
        ),
      );
    }
  }

  ExamScoreReport submit({required DateTime submittedAtUtc}) {
    final current = state;
    final existing = current.report;
    if (existing != null) return existing;
    if (!submittedAtUtc.isUtc) {
      throw ArgumentError('submittedAtUtc must be UTC');
    }
    return _finish(submittedAtUtc, timedOut: false);
  }

  ExamScoreReport _finish(
    DateTime submittedAtUtc, {
    required bool timedOut,
  }) {
    final current = state;
    final report = ExamScoringEngine.score(
      exam: current.exam,
      answers: current.session.answers,
    );
    _timer?.cancel();
    _timer = null;
    _emit(
      ExamSessionState(
        exam: current.exam,
        session: current.session.copyWith(
          submittedAtUtc: submittedAtUtc.toUtc(),
          timedOut: timedOut,
        ),
        remainingSeconds: 0,
        report: report,
      ),
    );
    return report;
  }

  void _moveTo(int index) {
    final current = state;
    _emit(
      ExamSessionState(
        exam: current.exam,
        session: current.session.copyWith(currentQuestionIndex: index),
        remainingSeconds: current.remainingSeconds,
        report: current.report,
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed || _state == null || state.isFinished) return;
      synchronize(DateTime.now().toUtc());
    });
  }

  void _emit(ExamSessionState next) {
    _state = next;
    if (!_changes.isClosed) _changes.add(next);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    await _changes.close();
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('ExamSessionNotifier is disposed');
    }
  }
}
