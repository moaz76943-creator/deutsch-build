import 'speaking_exam_models.dart';

abstract interface class SpeakingExamRepository {
  Future<List<SpeakingExamScenario>> getScenarios({
    ExamProvider? provider,
    ExamLevel? level,
  });
}
