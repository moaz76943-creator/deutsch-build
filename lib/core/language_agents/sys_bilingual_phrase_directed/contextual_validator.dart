import 'bilingual_models.dart';

final class ContextualValidator {
  const ContextualValidator();

  ContextValidationResult validate({
    required DirectedPhrase phrase,
    required LifeContext requestedContext,
  }) {
    if (phrase.sourceLanguageId.trim().isEmpty ||
        phrase.targetLanguageId.trim().isEmpty ||
        phrase.sourceLanguageId == phrase.targetLanguageId) {
      return const ContextValidationResult.invalid(
        'invalid_directed_pair',
        'source and target languages must be distinct and explicit',
      );
    }

    if (phrase.context != requestedContext) {
      return const ContextValidationResult.invalid(
        'context_mismatch',
        'phrase is not approved for the requested life context',
      );
    }

    if (phrase.sourceText.trim().isEmpty || phrase.targetText.trim().isEmpty) {
      return const ContextValidationResult.invalid(
        'empty_phrase',
        'source and target text must both be present',
      );
    }

    final sourceSlots = _slotsIn(phrase.sourceText);
    final targetSlots = _slotsIn(phrase.targetText);
    final declared = phrase.semanticSlots.toSet();

    if (!sourceSlots.containsAll(declared) ||
        !targetSlots.containsAll(declared)) {
      return const ContextValidationResult.invalid(
        'semantic_slot_missing',
        'declared semantic slots must survive source and target',
      );
    }

    if (!declared.containsAll(sourceSlots) ||
        !declared.containsAll(targetSlots)) {
      return const ContextValidationResult.invalid(
        'undeclared_semantic_slot',
        'all placeholders must be declared explicitly',
      );
    }

    if (phrase.register == PhraseRegister.formal &&
        phrase.context == LifeContext.greeting &&
        phrase.targetText.trim().length < 3) {
      return const ContextValidationResult.invalid(
        'formal_register_too_weak',
        'formal greeting output is underspecified',
      );
    }

    return const ContextValidationResult.valid();
  }

  static Set<String> _slotsIn(String text) {
    final matches = RegExp(r'\{([a-zA-Z0-9_]+)\}').allMatches(text);
    return <String>{
      for (final match in matches)
        if (match.group(1) != null) match.group(1)!,
    };
  }
}
