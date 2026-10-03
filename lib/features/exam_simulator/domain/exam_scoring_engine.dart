import 'exam_models.dart';

abstract final class ExamScoringEngine {
  static const int passThreshold = 60;

  static ExamScoreReport score({
    required ExamDefinition exam,
    required Map<String, int> answers,
  }) {
    final sectionEarned = <ExamSection, int>{
      for (final section in ExamSection.values) section: 0,
    };
    final sectionPossible = <ExamSection, int>{
      for (final section in ExamSection.values) section: 0,
    };

    var earned = 0;
    for (final question in exam.questions) {
      sectionPossible[question.section] =
          sectionPossible[question.section]! + question.points;
      final selected = answers[question.id];
      final valid = selected != null &&
          selected >= 0 &&
          selected < question.options.length;
      if (valid && selected == question.correctOptionIndex) {
        earned += question.points;
        sectionEarned[question.section] =
            sectionEarned[question.section]! + question.points;
      }
    }

    final totalPossible = exam.totalPoints;
    final normalizedScore = totalPossible <= 0
        ? 0
        : ((earned / totalPossible) * 100).round().clamp(0, 100).toInt();

    final sections = <ExamSection, ExamSectionScore>{};
    for (final section in ExamSection.values) {
      final possible = sectionPossible[section]!;
      final sectionValue = sectionEarned[section]!;
      final percentage = possible <= 0
          ? 0
          : ((sectionValue / possible) * 100)
              .round()
              .clamp(0, 100)
              .toInt();
      sections[section] = ExamSectionScore(
        section: section,
        earnedPoints: sectionValue,
        possiblePoints: possible,
        percentage: percentage,
      );
    }

    return ExamScoreReport(
      level: exam.level,
      totalScore: normalizedScore,
      passThreshold: passThreshold,
      passed: normalizedScore >= passThreshold,
      sections: Map<ExamSection, ExamSectionScore>.unmodifiable(sections),
    );
  }
}
