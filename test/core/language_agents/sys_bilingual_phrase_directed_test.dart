import 'package:deutsch_bilarabi/core/language_agents/sys_bilingual_phrase_directed/bilingual_engine_hub.dart';
import 'package:deutsch_bilarabi/core/language_agents/sys_bilingual_phrase_directed/bilingual_models.dart';
import 'package:deutsch_bilarabi/core/language_agents/sys_bilingual_phrase_directed/contextual_validator.dart';
import 'package:deutsch_bilarabi/core/language_agents/sys_bilingual_phrase_directed/directed_language_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mapper resolves only explicitly registered directed language paths', () {
    const mapper = DirectedLanguageMapper();

    final deToAr = mapper.map(
      sourceLanguageId: 'de',
      targetLanguageId: 'ar',
      sourceText: 'Wie viel kostet das?',
      context: LifeContext.shopping,
    );
    final arToDe = mapper.map(
      sourceLanguageId: 'ar',
      targetLanguageId: 'de',
      sourceText: 'كم سعر هذا؟',
      context: LifeContext.shopping,
    );
    final unsupported = mapper.map(
      sourceLanguageId: 'fr',
      targetLanguageId: 'ar',
      sourceText: 'Bonjour',
      context: LifeContext.greeting,
    );

    expect(deToAr?.targetText, 'كم سعر هذا؟');
    expect(arToDe?.targetText, 'Wie viel kostet das?');
    expect(deToAr?.pairId, 'de->ar');
    expect(arToDe?.pairId, 'ar->de');
    expect(unsupported, isNull);
  });

  test('context validator rejects wrong life context and missing semantic slots', () {
    const validator = ContextualValidator();

    const phrase = DirectedPhrase(
      id: 'de-ar-shopping-pay',
      sourceLanguageId: 'de',
      targetLanguageId: 'ar',
      sourceText: 'Kann ich mit {method} bezahlen?',
      targetText: 'هل يمكنني الدفع بواسطة {method}؟',
      context: LifeContext.shopping,
      register: PhraseRegister.polite,
      semanticSlots: <String>['method'],
    );

    expect(
      validator.validate(
        phrase: phrase,
        requestedContext: LifeContext.shopping,
      ).isValid,
      isTrue,
    );
    expect(
      validator.validate(
        phrase: phrase,
        requestedContext: LifeContext.health,
      ).code,
      'context_mismatch',
    );

    const broken = DirectedPhrase(
      id: 'broken',
      sourceLanguageId: 'de',
      targetLanguageId: 'ar',
      sourceText: 'Ich brauche {item}.',
      targetText: 'أحتاج هذا.',
      context: LifeContext.shopping,
      register: PhraseRegister.neutral,
      semanticSlots: <String>['item'],
    );
    expect(
      validator.validate(
        phrase: broken,
        requestedContext: LifeContext.shopping,
      ).code,
      'semantic_slot_missing',
    );
  });

  test('hub returns validated result and never pivots through another language', () {
    const hub = BilingualEngineHub();

    final result = hub.resolve(
      sourceLanguageId: 'de',
      targetLanguageId: 'ar',
      sourceText: 'Gute Besserung!',
      context: LifeContext.social,
    );

    expect(result.isAccepted, isTrue);
    expect(result.phrase?.targetText, 'سلامتك، أتمنى لك الشفاء العاجل!');
    expect(result.path, const <String>['de', 'ar']);

    final blocked = hub.resolve(
      sourceLanguageId: 'de',
      targetLanguageId: 'fr',
      sourceText: 'Gute Besserung!',
      context: LifeContext.social,
    );
    expect(blocked.isAccepted, isFalse);
    expect(blocked.code, 'direct_pair_not_registered');
  });
}
