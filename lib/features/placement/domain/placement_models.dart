enum PlacementLevel {
  a1(0, 'A1'),
  a2(1, 'A2'),
  b1(2, 'B1'),
  b2(3, 'B2');

  const PlacementLevel(this.rank, this.label);

  final int rank;
  final String label;

  int get recommendedStartTaskOrder => switch (this) {
        PlacementLevel.a1 => 1,
        PlacementLevel.a2 => 21,
        PlacementLevel.b1 => 31,
        PlacementLevel.b2 => 41,
      };

  static PlacementLevel fromRank(int rank) => switch (rank.clamp(0, 3)) {
        0 => PlacementLevel.a1,
        1 => PlacementLevel.a2,
        2 => PlacementLevel.b1,
        _ => PlacementLevel.b2,
      };
}

enum PlacementLearningGoal {
  general,
  dailyLife,
  work,
  studyExam,
  travel,
}

enum PlacementQuestionPattern {
  multipleChoice,
  grammar,
  translation,
  listening,
}

final class PlacementOption {
  const PlacementOption({
    required this.id,
    required this.text,
  });

  final String id;
  final String text;
}

final class PlacementQuestion {
  PlacementQuestion({
    required this.id,
    required this.promptArabic,
    required this.level,
    required this.pattern,
    required List<PlacementOption> options,
    required this.correctOptionId,
    required this.skillTag,
    this.audioText,
    this.audioLanguageCode = 'de',
    this.reviewItemId,
  }) : options = List<PlacementOption>.unmodifiable(options) {
    if (id.trim().isEmpty ||
        promptArabic.trim().isEmpty ||
        skillTag.trim().isEmpty ||
        options.length < 2 ||
        !options.any((option) => option.id == correctOptionId)) {
      throw ArgumentError('Invalid placement question.');
    }
  }

  final String id;
  final String promptArabic;
  final PlacementLevel level;
  final PlacementQuestionPattern pattern;
  final List<PlacementOption> options;
  final String correctOptionId;
  final String skillTag;
  final String? audioText;
  final String audioLanguageCode;
  final String? reviewItemId;

  bool get hasAudio => audioText?.trim().isNotEmpty == true;

  bool isCorrect(String optionId) => optionId == correctOptionId;
}

final class PlacementAnswer {
  const PlacementAnswer({
    required this.questionId,
    required this.questionLevel,
    required this.pattern,
    required this.skillTag,
    required this.selectedOptionId,
    required this.correct,
    this.reviewItemId,
  });

  final String questionId;
  final PlacementLevel questionLevel;
  final PlacementQuestionPattern pattern;
  final String skillTag;
  final String selectedOptionId;
  final bool correct;
  final String? reviewItemId;
}

final class AssessmentSession {
  const AssessmentSession({
    required this.id,
    required this.startedAt,
    required this.currentLevel,
    required this.abilityEstimate,
    required this.answers,
    required this.maxQuestions,
    this.completed = false,
  });

  final String id;
  final DateTime startedAt;
  final PlacementLevel currentLevel;
  final double abilityEstimate;
  final List<PlacementAnswer> answers;
  final int maxQuestions;
  final bool completed;

  double get progress =>
      (answers.length / maxQuestions).clamp(0.0, 1.0).toDouble();

  Set<String> get answeredQuestionIds =>
      answers.map((answer) => answer.questionId).toSet();

  AssessmentSession copyWith({
    PlacementLevel? currentLevel,
    double? abilityEstimate,
    List<PlacementAnswer>? answers,
    bool? completed,
  }) =>
      AssessmentSession(
        id: id,
        startedAt: startedAt,
        currentLevel: currentLevel ?? this.currentLevel,
        abilityEstimate: abilityEstimate ?? this.abilityEstimate,
        answers: answers ?? this.answers,
        maxQuestions: maxQuestions,
        completed: completed ?? this.completed,
      );
}

final class PlacementResult {
  const PlacementResult({
    required this.level,
    required this.proficiencyScore,
    required this.confidence,
    required this.answeredCount,
    required this.correctCount,
    required this.recommendations,
    required this.reviewItemIds,
    required this.initialReviewIntervalDays,
    required this.initialSrsDifficulty,
    this.learningGoal,
  });

  final PlacementLevel level;
  final double proficiencyScore;
  final double confidence;
  final int answeredCount;
  final int correctCount;
  final List<String> recommendations;
  final List<String> reviewItemIds;
  final int initialReviewIntervalDays;
  final double initialSrsDifficulty;
  final PlacementLearningGoal? learningGoal;

  PlacementResult copyWith({
    PlacementLearningGoal? learningGoal,
  }) =>
      PlacementResult(
        level: level,
        proficiencyScore: proficiencyScore,
        confidence: confidence,
        answeredCount: answeredCount,
        correctCount: correctCount,
        recommendations: recommendations,
        reviewItemIds: reviewItemIds,
        initialReviewIntervalDays: initialReviewIntervalDays,
        initialSrsDifficulty: initialSrsDifficulty,
        learningGoal: learningGoal ?? this.learningGoal,
      );
}
