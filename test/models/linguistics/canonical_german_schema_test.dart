import 'package:deutsch_bilarabi/models/linguistics/german_grammar_types.dart';
import 'package:deutsch_bilarabi/models/linguistics/german_noun.dart';
import 'package:deutsch_bilarabi/models/linguistics/german_noun_forms.dart';
import 'package:deutsch_bilarabi/models/linguistics/german_verb.dart';
import 'package:deutsch_bilarabi/models/linguistics/linguistic_concept.dart';
import 'package:deutsch_bilarabi/models/linguistics/verb_valency_frame.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'noun retains case-specific forms without flattening gender metadata',
    () {
      const concept = LinguisticConcept(
        id: 'noun.student',
        senseId: 'student.person',
        lemma: 'Student',
        partOfSpeech: LinguisticPartOfSpeech.noun,
        register: LanguageRegister.neutral,
        cefr: CefrLevel.a1,
      );
      const noun = GermanNoun(
        concept: concept,
        gender: GermanGender.masculine,
        plural: 'Studenten',
        declensionClass: GermanNounDeclensionClass.weak,
        caseForms: GermanNounCaseForms(
          nominativeSingular: 'Student',
          accusativeSingular: 'Studenten',
          dativeSingular: 'Studenten',
          genitiveSingular: 'Studenten',
          nominativePlural: 'Studenten',
          accusativePlural: 'Studenten',
          dativePlural: 'Studenten',
          genitivePlural: 'Studenten',
        ),
      );

      expect(
        noun.caseForms.formFor(GermanCase.accusative, plural: false),
        'Studenten',
      );
      expect(noun.gender, GermanGender.masculine);
      expect(noun.declensionClass, GermanNounDeclensionClass.weak);
    },
  );

  test(
    'verb models separability reflexivity auxiliary and valency separately',
    () {
      const concept = LinguisticConcept(
        id: 'verb.warten',
        senseId: 'warten.wait',
        lemma: 'warten',
        partOfSpeech: LinguisticPartOfSpeech.verb,
        register: LanguageRegister.neutral,
        cefr: CefrLevel.a1,
      );
      const verb = GermanVerb(
        concept: concept,
        infinitive: 'warten',
        reflexivity: GermanReflexivity.none,
        auxiliary: GermanAuxiliary.haben,
        participleII: 'gewartet',
        valencyFrames: <VerbValencyFrame>[
          VerbValencyFrame(
            frameId: 'prep_auf',
            semanticRole: 'target',
            preposition: 'auf',
            prepositionCase: GermanCase.accusative,
          ),
        ],
      );

      expect(verb.auxiliary, GermanAuxiliary.haben);
      expect(verb.isSeparable, isFalse);
      expect(verb.valencyFrames.single.preposition, 'auf');
      expect(verb.valencyFrames.single.prepositionCase, GermanCase.accusative);
      expect(verb.valencyFrames.single.hasGovernment, isTrue);
    },
  );
}
