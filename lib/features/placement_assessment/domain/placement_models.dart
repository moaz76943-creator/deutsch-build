enum CefrLevel { a1, a2, b1, b2 }

enum AssessmentSkillCategory {
  grammar,
  vocabulary,
  readingComprehension,
  practicalContext,
}

extension CefrLevelMetadata on CefrLevel {
  int get rank => switch (this) {
        CefrLevel.a1 => 0,
        CefrLevel.a2 => 1,
        CefrLevel.b1 => 2,
        CefrLevel.b2 => 3,
      };

  String get label => switch (this) {
        CefrLevel.a1 => 'A1',
        CefrLevel.a2 => 'A2',
        CefrLevel.b1 => 'B1',
        CefrLevel.b2 => 'B2',
      };

  static CefrLevel fromRank(int rank) => switch (rank.clamp(0, 3)) {
        0 => CefrLevel.a1,
        1 => CefrLevel.a2,
        2 => CefrLevel.b1,
        _ => CefrLevel.b2,
      };
}

extension AssessmentSkillCategoryLabel on AssessmentSkillCategory {
  String get arabicLabel => switch (this) {
        AssessmentSkillCategory.grammar => 'القواعد',
        AssessmentSkillCategory.vocabulary => 'المفردات',
        AssessmentSkillCategory.readingComprehension => 'فهم المقروء',
        AssessmentSkillCategory.practicalContext => 'السياق العملي',
      };
}

final class PlacementQuestionItem {
  PlacementQuestionItem({
    required this.id,
    required this.question,
    required List<String> options,
    required this.correctAnswerIndex,
    required this.targetLevel,
    required this.difficultyWeight,
    required this.skill,
    required this.arabicExplanation,
  }) : options = List<String>.unmodifiable(options) {
    if (id.trim().isEmpty ||
        question.trim().isEmpty ||
        options.length < 2 ||
        correctAnswerIndex < 0 ||
        correctAnswerIndex >= options.length ||
        difficultyWeight <= 0 ||
        arabicExplanation.trim().isEmpty) {
      throw ArgumentError('Invalid placement question.');
    }
  }

  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final CefrLevel targetLevel;
  final double difficultyWeight;
  final AssessmentSkillCategory skill;
  final String arabicExplanation;

  bool isCorrect(int optionIndex) => optionIndex == correctAnswerIndex;
}

final class PlacementAnswerRecord {
  const PlacementAnswerRecord({
    required this.questionId,
    required this.level,
    required this.skill,
    required this.difficultyWeight,
    required this.isCorrect,
  });

  final String questionId;
  final CefrLevel level;
  final AssessmentSkillCategory skill;
  final double difficultyWeight;
  final bool isCorrect;
}

final class PlacementResult {
  PlacementResult({
    required this.finalLevel,
    required double standardizedScore,
    required Map<AssessmentSkillCategory, double> skillAccuracy,
    required List<String> learningPlan,
  })  : standardizedScore =
            standardizedScore.clamp(0.0, 100.0).toDouble(),
        skillAccuracy =
            Map<AssessmentSkillCategory, double>.unmodifiable(
          <AssessmentSkillCategory, double>{
            for (final entry in skillAccuracy.entries)
              entry.key: entry.value.clamp(0.0, 1.0).toDouble(),
          },
        ),
        learningPlan = List<String>.unmodifiable(learningPlan);

  final CefrLevel finalLevel;
  final double standardizedScore;
  final Map<AssessmentSkillCategory, double> skillAccuracy;
  final List<String> learningPlan;
}
