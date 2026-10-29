enum CefrExamLevel {
  a1('A1'),
  a2('A2');

  const CefrExamLevel(this.label);
  final String label;
}

enum ExamSection {
  lesen('Lesen'),
  hoeren('Hören'),
  schreiben('Schreiben');

  const ExamSection(this.label);
  final String label;
}

final class ExamQuestion {
  const ExamQuestion({
    required this.id,
    required this.section,
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
    required this.points,
    this.stimulus,
  })  : assert(options.length >= 2),
        assert(correctOptionIndex >= 0),
        assert(correctOptionIndex < options.length),
        assert(points > 0);

  final String id;
  final ExamSection section;
  final String prompt;
  final String? stimulus;
  final List<String> options;
  final int correctOptionIndex;
  final int points;
}

final class ExamDefinition {
  const ExamDefinition({
    required this.id,
    required this.level,
    required this.title,
    required this.duration,
    required this.questions,
  }) : assert(questions.length > 0);

  final String id;
  final CefrExamLevel level;
  final String title;
  final Duration duration;
  final List<ExamQuestion> questions;

  int get totalPoints =>
      questions.fold<int>(0, (sum, question) => sum + question.points);
}

final class ExamSession {
  const ExamSession({
    required this.examId,
    required this.startedAtUtc,
    required this.durationSeconds,
    required this.currentQuestionIndex,
    required this.answers,
    this.submittedAtUtc,
    this.timedOut = false,
  })  : assert(durationSeconds > 0),
        assert(currentQuestionIndex >= 0);

  final String examId;
  final DateTime startedAtUtc;
  final int durationSeconds;
  final int currentQuestionIndex;
  final Map<String, int> answers;
  final DateTime? submittedAtUtc;
  final bool timedOut;

  bool get isFinished => submittedAtUtc != null;

  DateTime get deadlineUtc =>
      startedAtUtc.add(Duration(seconds: durationSeconds));

  int remainingSeconds(DateTime nowUtc) {
    if (isFinished) return 0;
    final value = deadlineUtc.difference(nowUtc.toUtc()).inSeconds;
    return value.clamp(0, durationSeconds).toInt();
  }

  ExamSession copyWith({
    int? currentQuestionIndex,
    Map<String, int>? answers,
    DateTime? submittedAtUtc,
    bool? timedOut,
  }) {
    return ExamSession(
      examId: examId,
      startedAtUtc: startedAtUtc,
      durationSeconds: durationSeconds,
      currentQuestionIndex:
          currentQuestionIndex ?? this.currentQuestionIndex,
      answers: Map<String, int>.unmodifiable(answers ?? this.answers),
      submittedAtUtc: submittedAtUtc ?? this.submittedAtUtc,
      timedOut: timedOut ?? this.timedOut,
    );
  }
}

final class ExamSectionScore {
  const ExamSectionScore({
    required this.section,
    required this.earnedPoints,
    required this.possiblePoints,
    required this.percentage,
  });

  final ExamSection section;
  final int earnedPoints;
  final int possiblePoints;
  final int percentage;
}

final class ExamScoreReport {
  const ExamScoreReport({
    required this.level,
    required this.totalScore,
    required this.passThreshold,
    required this.passed,
    required this.sections,
  });

  final CefrExamLevel level;
  final int totalScore;
  final int passThreshold;
  final bool passed;
  final Map<ExamSection, ExamSectionScore> sections;
}
