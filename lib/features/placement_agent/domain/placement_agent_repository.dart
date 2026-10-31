import 'placement_agent_models.dart';

abstract class PlacementAgentRepository {
  Future<List<PlacementQuestionItem>> getCalibratedQuestions();

  Future<void> saveAssessmentResult(PlacementAssessmentResult result);

  Future<PlacementAssessmentResult?> getLatestResult();
}

abstract interface class AdaptivePlacementQuestionSource {
  PlacementQuestionItem? selectNextQuestion({
    required Set<String> answeredIds,
    required int targetDifficulty,
  });
}
