import 'buergeramt_models.dart';

abstract interface class BuergeramtRepository {
  Future<List<BureaucracyScenario>> getSituations();

  Future<List<BureaucracyDialogueTurn>> getDialogue(String scenarioId);

  Future<bool> checkChoice({
    required String scenarioId,
    required String turnId,
    required String choiceId,
  });
}
