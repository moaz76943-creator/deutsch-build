import 'package:deutsch_bilarabi/data/canonical_grammar_catalog.dart';
import 'package:deutsch_bilarabi/models/grammar.dart';
import 'package:deutsch_bilarabi/models/linguistics/german_grammar_types.dart';
import 'package:deutsch_bilarabi/models/linguistics/german_noun.dart';
import 'package:deutsch_bilarabi/models/linguistics/german_noun_forms.dart';
import 'package:deutsch_bilarabi/models/linguistics/german_verb.dart';
import 'package:deutsch_bilarabi/models/linguistics/linguistic_concept.dart';
import 'package:deutsch_bilarabi/models/linguistics/verb_valency_frame.dart';
import 'package:deutsch_bilarabi/services/linguistics/german_linguistic_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validator = GermanLinguisticValidator();

  test('canonical grammar catalog has no QA errors', () {
    final report = validator.validateGrammarCatalog(
      CanonicalGrammarCatalog.allTopics,
    );

    expect(report.errors, isEmpty);
    expect(report.isValid, isTrue);
  });

  test('noun QA rejects gender and plural/case inconsistencies', () {
    const noun = GermanNoun(
      concept: LinguisticConcept(
        id: 'noun.bad',
        senseId: 'noun.bad',
        lemma: 'Student',
        partOfSpeech: LinguisticPartOfSpeech.noun,
        register: LanguageRegister.neutral,
        cefr: CefrLevel.a1,
      ),
      gender: GermanGender.unknown,
      plural: 'Studenten',
      declensionClass: GermanNounDeclensionClass.weak,
      caseForms: GermanNounCaseForms(
        nominativeSingular: 'Student',
        accusativeSingular: 'Studenten',
        dativeSingular: 'Studenten',
        genitiveSingular: 'Studenten',
        nominativePlural: 'Studente',
        accusativePlural: 'Studenten',
        dativePlural: 'Studenten',
        genitivePlural: 'Studenten',
      ),
    );

    final report = validator.validateNoun(noun);
    final codes = report.errors.map((issue) => issue.code).toSet();

    expect(codes, contains('noun.gender_unresolved'));
    expect(codes, contains('noun.plural_mismatch'));
  });

  test('verb QA rejects conflicting prefixes and incomplete valency', () {
    const verb = GermanVerb(
      concept: LinguisticConcept(
        id: 'verb.bad',
        senseId: 'verb.bad',
        lemma: 'warten',
        partOfSpeech: LinguisticPartOfSpeech.verb,
        register: LanguageRegister.neutral,
        cefr: CefrLevel.a1,
      ),
      infinitive: 'warten',
      separablePrefix: 'ab',
      inseparablePrefix: 'be',
      reflexivity: GermanReflexivity.none,
      auxiliary: GermanAuxiliary.haben,
      valencyFrames: <VerbValencyFrame>[
        VerbValencyFrame(
          frameId: 'broken',
          semanticRole: 'target',
          preposition: 'auf',
        ),
      ],
    );

    final report = validator.validateVerb(verb);
    final codes = report.errors.map((issue) => issue.code).toSet();

    expect(codes, contains('verb.prefix_conflict'));
    expect(codes, contains('verb.separable_prefix_mismatch'));
    expect(codes, contains('valency.preposition_case_pair'));
  });

  test('grammar QA rejects duplicate ids and invalid quiz index', () {
    const topics = <GrammarTopic>[
      GrammarTopic(
        id: 'a1_test',
        level: 'A1',
        titleDe: 'Test',
        titleAr: 'اختبار',
        summaryAr: 'شرح',
        rules: <GrammarRule>[
          GrammarRule(
            id: 'rule.same',
            title: 'قاعدة',
            explanationAr: 'شرح القاعدة',
          ),
        ],
        miniChecks: <MiniCheckQuestion>[
          MiniCheckQuestion(
            id: 'quiz.same',
            questionText: 'Frage?',
            options: <String>['A', 'B'],
            correctAnswerIndex: 4,
            explanationAr: 'شرح',
          ),
        ],
      ),
      GrammarTopic(
        id: 'a1_test',
        level: 'A1',
        titleDe: 'Test 2',
        titleAr: 'اختبار 2',
        summaryAr: 'شرح 2',
        rules: <GrammarRule>[
          GrammarRule(
            id: 'rule.same',
            title: 'قاعدة ثانية',
            explanationAr: 'شرح',
          ),
        ],
        miniChecks: <MiniCheckQuestion>[
          MiniCheckQuestion(
            id: 'quiz.same',
            questionText: 'Andere Frage?',
            options: <String>['A', 'B'],
            correctAnswerIndex: 0,
            explanationAr: 'شرح',
          ),
        ],
      ),
    ];

    final report = validator.validateGrammarCatalog(topics);
    final codes = report.errors.map((issue) => issue.code).toSet();

    expect(codes, contains('grammar.duplicate_topic_id'));
    expect(codes, contains('grammar.duplicate_rule_id'));
    expect(codes, contains('grammar.duplicate_quiz_id'));
    expect(codes, contains('grammar.quiz_index_out_of_range'));
  });
}
