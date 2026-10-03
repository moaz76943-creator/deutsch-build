import 'placement_models.dart';

abstract class PlacementRepository {
  Future<List<PlacementQuestionItem>> getQuestionBundle({
    CefrLevel? level,
  });

  Future<PlacementQuestionItem?> nextAdaptiveQuestion({
    required CefrLevel targetLevel,
    required double targetDifficulty,
    required Set<String> excludeIds,
    required Map<AssessmentSkillCategory, int> skillAttempts,
  });

  PlacementResult calculateStandardizedResult(
    List<PlacementAnswerRecord> answers,
  );
}
