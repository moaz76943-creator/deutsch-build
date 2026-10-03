import 'email_builder_models.dart';

abstract interface class EmailBuilderRepository {
  Future<List<EmailScenario>> getScenarios();

  Future<List<EmailTemplateBlock>> getBlocks({
    required String scenarioId,
    LetterSection? section,
  });

  Future<bool> validateStructure(List<EmailTemplateBlock> blocks);

  Future<bool> isRegisterAppropriate({
    required String scenarioId,
    required EmailTemplateBlock block,
  });

  Future<bool> validatePhrase({
    required String scenarioId,
    required String blockId,
  });
}
