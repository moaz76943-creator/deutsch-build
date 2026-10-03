import 'bilingual_models.dart';
import 'contextual_validator.dart';
import 'directed_language_mapper.dart';

final class BilingualEngineHub {
  const BilingualEngineHub({
    this.mapper = const DirectedLanguageMapper(),
    this.validator = const ContextualValidator(),
  });

  final DirectedLanguageMapper mapper;
  final ContextualValidator validator;

  BilingualResolution resolve({
    required String sourceLanguageId,
    required String targetLanguageId,
    required String sourceText,
    required LifeContext context,
  }) {
    final phrase = mapper.map(
      sourceLanguageId: sourceLanguageId,
      targetLanguageId: targetLanguageId,
      sourceText: sourceText,
      context: context,
    );

    if (phrase == null) {
      return BilingualResolution.blocked(
        code: 'direct_pair_not_registered',
        sourceLanguageId: sourceLanguageId,
        targetLanguageId: targetLanguageId,
      );
    }

    final validation = validator.validate(
      phrase: phrase,
      requestedContext: context,
    );
    if (!validation.isValid) {
      return BilingualResolution.blocked(
        code: validation.code,
        sourceLanguageId: sourceLanguageId,
        targetLanguageId: targetLanguageId,
      );
    }

    return BilingualResolution.accepted(phrase);
  }

  List<DirectedPhrase> catalog({
    required String sourceLanguageId,
    required String targetLanguageId,
    LifeContext? context,
  }) =>
      mapper.entriesFor(
        sourceLanguageId: sourceLanguageId,
        targetLanguageId: targetLanguageId,
        context: context,
      );
}
