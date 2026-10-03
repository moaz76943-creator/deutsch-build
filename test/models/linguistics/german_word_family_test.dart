import 'package:deutsch_bilarabi/models/linguistics/german_word_family.dart';
import 'package:deutsch_bilarabi/models/linguistics/linguistic_concept.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('word family requires explicit semantic relation metadata', () {
    const member = GermanWordFamilyMember(
      concept: LinguisticConcept(
        id: 'verb.abfahren',
        senseId: 'abfahren.depart',
        lemma: 'abfahren',
        partOfSpeech: LinguisticPartOfSpeech.verb,
        register: LanguageRegister.neutral,
        cefr: CefrLevel.a1,
      ),
      relationType: GermanWordFamilyRelationType.prefixedVerb,
      prefix: 'ab',
      semanticDistance: GermanSemanticDistance.low,
      pedagogicalLevel: CefrLevel.a1,
      interferenceRisk: false,
    );

    expect(member.relationType.wireName, 'prefixed_verb');
    expect(member.prefix, 'ab');
    expect(member.isBase, isFalse);
  });

  test(
    'potentially confusing relatives remain explicit rather than merged',
    () {
      const member = GermanWordFamilyMember(
        concept: LinguisticConcept(
          id: 'verb.erfahren',
          senseId: 'erfahren.learn',
          lemma: 'erfahren',
          partOfSpeech: LinguisticPartOfSpeech.verb,
          register: LanguageRegister.neutral,
          cefr: CefrLevel.a2,
        ),
        relationType: GermanWordFamilyRelationType.semanticRelative,
        semanticDistance: GermanSemanticDistance.high,
        pedagogicalLevel: CefrLevel.a2,
        interferenceRisk: true,
      );

      expect(member.semanticDistance, GermanSemanticDistance.high);
      expect(member.interferenceRisk, isTrue);
    },
  );
}
