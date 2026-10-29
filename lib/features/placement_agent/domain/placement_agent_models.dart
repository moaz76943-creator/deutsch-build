enum LanguageCefrSubLevel { a1_1, a1_2, a2_1, a2_2 }

enum PlacementQuestionFocus { grammar, vocabulary }

final class PlacementQuestionItem {
  const PlacementQuestionItem({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.difficulty,
    required this.targetSkill,
    required this.focus,
  })  : assert(id.length > 0),
        assert(options.length >= 2),
        assert(correctAnswerIndex >= 0),
        assert(correctAnswerIndex < options.length),
        assert(difficulty >= 1 && difficulty <= 5);

  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final int difficulty;
  final String targetSkill;
  final PlacementQuestionFocus focus;

  bool isCorrect(int selectedIndex) => selectedIndex == correctAnswerIndex;
}

final class PlacementAssessmentResult {
  PlacementAssessmentResult({
    required this.inferredLevel,
    required double accuracy,
    required List<String> masteredSkills,
    required List<String> skillsToStrengthen,
  })  : accuracy = accuracy.clamp(0.0, 1.0).toDouble(),
        masteredSkills = List<String>.unmodifiable(masteredSkills),
        skillsToStrengthen = List<String>.unmodifiable(skillsToStrengthen);

  final LanguageCefrSubLevel inferredLevel;
  final double accuracy;
  final List<String> masteredSkills;
  final List<String> skillsToStrengthen;
}

extension LanguageCefrSubLevelLabel on LanguageCefrSubLevel {
  String get label => switch (this) {
        LanguageCefrSubLevel.a1_1 => 'A1.1',
        LanguageCefrSubLevel.a1_2 => 'A1.2',
        LanguageCefrSubLevel.a2_1 => 'A2.1',
        LanguageCefrSubLevel.a2_2 => 'A2.2',
      };
}
