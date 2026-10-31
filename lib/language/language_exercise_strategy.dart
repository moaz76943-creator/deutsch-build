import '../core/content_contract.dart';
import '../models/assessment.dart';
import '../models/conversation.dart';
import '../models/mistake.dart';
import '../models/production.dart';

/// Language-neutral exercise boundary.
///
/// Implementations own localized prompts, expected language, and scenario
/// content. Core exercise engines own selection, scoring, and lifecycle.
abstract interface class LanguageExerciseStrategy {
  AssessmentQuestion assessmentQuestion(
    LearningContent item,
    int index,
    int seed,
  );
  ProductionTask? productionTask(
    LearningContent item, {
    MistakeRecord? mistake,
    ProductionMode? mode,
  });
  RepairDrill? repairDrill(LearningContent? item, MistakeRecord mistake);
  List<ConversationScenario> get conversationScenarios;
}
