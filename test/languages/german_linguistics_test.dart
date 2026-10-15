import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/models/linguistics/german_grammar_types.dart';
import 'package:deutsch_bilarabi/languages/german/adjective_declension_engine.dart';
import 'package:deutsch_bilarabi/languages/german/tekamolo_engine.dart';
import 'package:deutsch_bilarabi/languages/german/compound_splitter.dart';
import 'package:deutsch_bilarabi/languages/german/satzklammer_analyzer.dart';
import 'package:deutsch_bilarabi/languages/german/verb_valency_engine.dart';
import 'package:deutsch_bilarabi/core/linguistics/typo_tolerance_matcher.dart';
import 'package:deutsch_bilarabi/core/linguistics/cefr_estimator.dart';
import 'package:deutsch_bilarabi/core/catalog/directed_readiness_engine.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pack_gate.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/languages/german/gender_engine.dart';
import 'package:deutsch_bilarabi/languages/german/verb_conjugator.dart';

void main() {
  group('GermanAdjectiveDeclensionEngine Tests (Study 62)', () {
    test('Weak declension: definite article (der/die/das)', () {
      // der gute Mann (nom masc)
      final nomMasc = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'gut',
        declensionType: AdjectiveDeclensionType.weak,
        grammaticalCase: GermanCase.nominative,
        gender: GermanGender.masculine,
      );
      expect(nomMasc.ending, 'e');
      expect(nomMasc.declinedForm, 'gute');

      // den guten Mann (acc masc)
      final accMasc = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'gut',
        declensionType: AdjectiveDeclensionType.weak,
        grammaticalCase: GermanCase.accusative,
        gender: GermanGender.masculine,
      );
      expect(accMasc.ending, 'en');
      expect(accMasc.declinedForm, 'guten');

      // dem guten Mann (dat masc)
      final datMasc = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'gut',
        declensionType: AdjectiveDeclensionType.weak,
        grammaticalCase: GermanCase.dative,
        gender: GermanGender.masculine,
      );
      expect(datMasc.ending, 'en');
      expect(datMasc.declinedForm, 'guten');

      // die schöne Frau (nom fem)
      final nomFem = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'schön',
        declensionType: AdjectiveDeclensionType.weak,
        grammaticalCase: GermanCase.nominative,
        gender: GermanGender.feminine,
      );
      expect(nomFem.ending, 'e');
      expect(nomFem.declinedForm, 'schöne');

      // das kleine Kind (nom neut)
      final nomNeut = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'klein',
        declensionType: AdjectiveDeclensionType.weak,
        grammaticalCase: GermanCase.nominative,
        gender: GermanGender.neuter,
      );
      expect(nomNeut.ending, 'e');
      expect(nomNeut.declinedForm, 'kleine');

      // die kleinen Kinder (nom plural)
      final nomPlural = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'klein',
        declensionType: AdjectiveDeclensionType.weak,
        grammaticalCase: GermanCase.nominative,
        gender: GermanGender.neuter,
        number: GrammaticalNumber.plural,
      );
      expect(nomPlural.ending, 'en');
      expect(nomPlural.declinedForm, 'kleinen');
    });

    test('Mixed declension: indefinite article (ein/eine/kein)', () {
      // ein guter Mann (nom masc)
      final nomMasc = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'gut',
        declensionType: AdjectiveDeclensionType.mixed,
        grammaticalCase: GermanCase.nominative,
        gender: GermanGender.masculine,
      );
      expect(nomMasc.ending, 'er');
      expect(nomMasc.declinedForm, 'guter');

      // ein kleines Kind (nom neut)
      final nomNeut = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'klein',
        declensionType: AdjectiveDeclensionType.mixed,
        grammaticalCase: GermanCase.nominative,
        gender: GermanGender.neuter,
      );
      expect(nomNeut.ending, 'es');
      expect(nomNeut.declinedForm, 'kleines');

      // eine schöne Frau (nom fem)
      final nomFem = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'schön',
        declensionType: AdjectiveDeclensionType.mixed,
        grammaticalCase: GermanCase.nominative,
        gender: GermanGender.feminine,
      );
      expect(nomFem.ending, 'e');
      expect(nomFem.declinedForm, 'schöne');
    });

    test('Strong declension: zero article', () {
      // kalter Kaffee (nom masc)
      final nomMasc = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'kalt',
        declensionType: AdjectiveDeclensionType.strong,
        grammaticalCase: GermanCase.nominative,
        gender: GermanGender.masculine,
      );
      expect(nomMasc.ending, 'er');
      expect(nomMasc.declinedForm, 'kalter');

      // mit kaltem Wasser (dat neut)
      final datNeut = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'kalt',
        declensionType: AdjectiveDeclensionType.strong,
        grammaticalCase: GermanCase.dative,
        gender: GermanGender.neuter,
      );
      expect(datNeut.ending, 'em');
      expect(datNeut.declinedForm, 'kaltem');
    });

    test('Stem adjustments: dunkel -> dunkle, teuer -> teure, hoch -> hohe', () {
      final dunkel = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'dunkel',
        declensionType: AdjectiveDeclensionType.weak,
        grammaticalCase: GermanCase.nominative,
        gender: GermanGender.neuter,
      );
      expect(dunkel.declinedForm, 'dunkle');

      final teuer = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'teuer',
        declensionType: AdjectiveDeclensionType.weak,
        grammaticalCase: GermanCase.nominative,
        gender: GermanGender.feminine,
      );
      expect(teuer.declinedForm, 'teure');

      final hoch = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'hoch',
        declensionType: AdjectiveDeclensionType.weak,
        grammaticalCase: GermanCase.nominative,
        gender: GermanGender.neuter,
      );
      expect(hoch.declinedForm, 'hohe');
    });

    test('Invariable adjectives remain unchanged', () {
      final lila = GermanAdjectiveDeclensionEngine.decline(
        adjectiveBase: 'lila',
        declensionType: AdjectiveDeclensionType.weak,
        grammaticalCase: GermanCase.accusative,
        gender: GermanGender.feminine,
      );
      expect(lila.declinedForm, 'lila');
      expect(lila.ending, '');
    });
  });

  group('TeKaMoLoEngine Tests (Study 56)', () {
    test('Classification of individual adverbial phrases', () {
      expect(TeKaMoLoEngine.classifyAdverbial('heute').category, AdverbialCategory.temporal);
      expect(TeKaMoLoEngine.classifyAdverbial('um 10 Uhr').category, AdverbialCategory.temporal);
      expect(TeKaMoLoEngine.classifyAdverbial('wegen des Wetters').category, AdverbialCategory.kausal);
      expect(TeKaMoLoEngine.classifyAdverbial('mit dem Bus').category, AdverbialCategory.modal);
      expect(TeKaMoLoEngine.classifyAdverbial('nach Berlin').category, AdverbialCategory.lokal);
      expect(TeKaMoLoEngine.classifyAdverbial('nach Hause').category, AdverbialCategory.lokal);
    });

    test('Canonical sequence verification', () {
      final canonical = ['heute', 'wegen des Regens', 'mit dem Bus', 'nach Berlin'];
      final result1 = TeKaMoLoEngine.verifyOrder(canonical);
      expect(result1.isCanonicalOrder, isTrue);

      final reversed = ['nach Berlin', 'heute'];
      final result2 = TeKaMoLoEngine.verifyOrder(reversed);
      expect(result2.isCanonicalOrder, isFalse);
      expect(result2.correctedOrder, ['heute', 'nach Berlin']);
    });
  });

  group('GermanCompoundSplitter Tests (Study 08)', () {
    test('Splits Wörterbuch into Wort + er + Buch (das)', () {
      final res = GermanCompoundSplitter.split('Wörterbuch');
      expect(res.isCompound, isTrue);
      expect(res.headWord, 'Buch');
      expect(res.headGender, GermanGender.neuter);
      expect(res.fugenElement, 'er');
    });

    test('Splits Flughafen into Flug + Hafen (der)', () {
      final res = GermanCompoundSplitter.split('Flughafen');
      expect(res.isCompound, isTrue);
      expect(res.headWord, 'Hafen');
      expect(res.headGender, GermanGender.masculine);
    });

    test('Splits Arbeitsplatz with -s- fugen element', () {
      final res = GermanCompoundSplitter.split('Arbeitsplatz');
      expect(res.isCompound, isTrue);
      expect(res.headWord, 'Platz');
      expect(res.headGender, GermanGender.masculine);
      expect(res.fugenElement, 's');
    });

    test('Short words are not marked as compound', () {
      final res = GermanCompoundSplitter.split('Buch');
      expect(res.isCompound, isFalse);
    });
  });

  group('SatzklammerAnalyzer Tests (Study 50)', () {
    test('V2 main clause with separable prefix: steht ... auf', () {
      final res = SatzklammerAnalyzer.analyze('Er steht jeden Morgen früh auf.');
      expect(res.clauseType, ClauseType.mainClauseV2);
      expect(res.leftBracket, 'steht');
      expect(res.rightBracket, 'auf');
      expect(res.hasSeparablePrefix, isTrue);
    });

    test('V2 main clause with non-finite verb: habe ... gelesen', () {
      final res = SatzklammerAnalyzer.analyze('Ich habe gestern ein Buch gelesen.');
      expect(res.clauseType, ClauseType.mainClauseV2);
      expect(res.leftBracket, 'habe');
      expect(res.rightBracket, 'gelesen');
    });

    test('Nebensatz verb-final: weil er heute krank ist', () {
      final res = SatzklammerAnalyzer.analyze('weil er heute krank ist');
      expect(res.clauseType, ClauseType.subordinateClauseEnd);
      expect(res.leftBracket, 'weil');
      expect(res.rightBracket, 'ist');
    });

    test('V1 Question: Kommst du morgen mit?', () {
      final res = SatzklammerAnalyzer.analyze('Kommst du morgen mit?');
      expect(res.clauseType, ClauseType.questionOrImperativeV1);
      expect(res.leftBracket, 'Kommst');
      expect(res.rightBracket, 'mit');
    });
  });

  group('VerbValencyEngine Tests (Study 44)', () {
    test('Dative verbs: helfen, danken, gehören', () {
      expect(VerbValencyEngine.getVerbValency('helfen').primaryCase, GermanCase.dative);
      expect(VerbValencyEngine.getVerbValency('danken').primaryCase, GermanCase.dative);
      expect(VerbValencyEngine.getVerbValency('gehören').primaryCase, GermanCase.dative);
    });

    test('Standard transitive verbs: kaufen -> accusative', () {
      expect(VerbValencyEngine.getVerbValency('kaufen').primaryCase, GermanCase.accusative);
    });

    test('Wechselpräpositionen: in with motion vs static location', () {
      final motion = VerbValencyEngine.evaluatePreposition('in', isDirectionalMotion: true);
      expect(motion.requiredCase, GermanCase.accusative);

      final location = VerbValencyEngine.evaluatePreposition('in', isDirectionalMotion: false);
      expect(location.requiredCase, GermanCase.dative);
    });

    test('Fixed accusative prepositions: für, ohne', () {
      expect(VerbValencyEngine.evaluatePreposition('für').requiredCase, GermanCase.accusative);
      expect(VerbValencyEngine.evaluatePreposition('ohne').requiredCase, GermanCase.accusative);
    });
  });

  group('TypoToleranceMatcher Tests (Study 14)', () {
    test('Damerau-Levenshtein transposition distance is 1', () {
      // Standard Levenshtein counts transposition as 2, Damerau counts it as 1
      expect(TypoToleranceMatcher.damerauLevenshtein('huas', 'haus'), 1);
      expect(TypoToleranceMatcher.damerauLevenshtein('apfel', 'apfle'), 1);
    });

    test('Umlaut alternative matching: ae for ä', () {
      final res = TypoToleranceMatcher.evaluateAnswer(
        learnerInput: 'Maedchen',
        expectedTarget: 'Mädchen',
      );
      expect(res.status, TypoMatchStatus.umlautAlternative);
      expect(res.isAccepted, isTrue);
    });

    test('Arabic diacritics stripping: ignore tashkeel', () {
      final res = TypoToleranceMatcher.evaluateAnswer(
        learnerInput: 'كِتَابٌ',
        expectedTarget: 'كتاب',
        isGerman: false,
      );
      expect(res.status, TypoMatchStatus.exactMatch);
      expect(res.isAccepted, isTrue);
    });
  });

  group('CefrEstimator Tests (Study 02)', () {
    test('Core vocabulary estimates A1', () {
      expect(CefrEstimator.estimateLevel('Wasser').estimatedLevel, CefrLevel.a1);
      expect(CefrEstimator.estimateLevel('Buch').estimatedLevel, CefrLevel.a1);
    });

    test('Intermediate and advanced suffixes estimate B1/C1', () {
      expect(CefrEstimator.estimateLevel('Freundschaft').estimatedLevel, CefrLevel.b1);
      expect(CefrEstimator.estimateLevel('Differenzierung').estimatedLevel, CefrLevel.c1);
    });
  });

  group('DirectedPairReadinessEngine Enhancements Tests', () {
    const pair = DirectedPairId(
      sourceLocale: 'ar',
      targetLocale: 'de',
      semanticVersion: '1.0.0',
    );

    test('Admitting directed pair allows transition to ready', () {
      final engine = DirectedPairReadinessEngine();
      engine.updatePackStatus(
        'de',
        const LanguagePackGateResult(PackGateStatus.approved),
      );

      // Before explicit admission: missing directed evidence
      expect(engine.resolvePair(pair).state, PairReadinessState.missingDirectedEvidence);

      // After admission: ready!
      engine.admitDirectedPair(pair);
      expect(engine.resolvePair(pair).state, PairReadinessState.ready);

      // Revoking: back to missing directed evidence
      engine.revokeDirectedPair(pair);
      expect(engine.resolvePair(pair).state, PairReadinessState.missingDirectedEvidence);
    });
  });

  group('GermanGenderEngine Tests (Study 38)', () {
    test('Documented exceptions with verified articles', () {
      expect(GermanGenderEngine.resolveGender('Fenster').gender, GermanGender.neuter);
      expect(GermanGenderEngine.resolveGender('Fenster').definiteArticle, 'das');
      expect(GermanGenderEngine.resolveGender('Fenster').isDocumentedException, isTrue);

      expect(GermanGenderEngine.resolveGender('Zimmer').gender, GermanGender.neuter);
      expect(GermanGenderEngine.resolveGender('Mutter').gender, GermanGender.feminine);
      expect(GermanGenderEngine.resolveGender('Mutter').definiteArticle, 'die');

      expect(GermanGenderEngine.resolveGender('Mädchen').gender, GermanGender.neuter);
      expect(GermanGenderEngine.resolveGender('Junge').gender, GermanGender.masculine);
      expect(GermanGenderEngine.resolveGender('Streik').gender, GermanGender.masculine);
      expect(GermanGenderEngine.resolveGender('Reichtum').gender, GermanGender.masculine);
    });

    test('Nominalized infinitives are neuter (das)', () {
      expect(GermanGenderEngine.resolveGender('Essen').gender, GermanGender.neuter);
      expect(GermanGenderEngine.resolveGender('Essen').definiteArticle, 'das');
      expect(GermanGenderEngine.resolveGender('Leben').gender, GermanGender.neuter);
      expect(GermanGenderEngine.resolveGender('Lernen').gender, GermanGender.neuter);
    });

    test('Standard suffix rules for feminine, masculine, neuter', () {
      expect(GermanGenderEngine.resolveGender('Zeitung').gender, GermanGender.feminine);
      expect(GermanGenderEngine.resolveGender('Freiheit').gender, GermanGender.feminine);
      expect(GermanGenderEngine.resolveGender('Möglichkeit').gender, GermanGender.feminine);
      expect(GermanGenderEngine.resolveGender('Optimismus').gender, GermanGender.masculine);
      expect(GermanGenderEngine.resolveGender('Dokument').gender, GermanGender.neuter);
    });
  });

  group('GermanVerbConjugator Tests (Studies 50 & 56)', () {
    test('Regular verb conjugation: lernen', () {
      final res = GermanVerbConjugator.conjugate('lernen');
      expect(res.isSeparable, isFalse);
      expect(res.presentForms[GermanPronoun.ich], 'lerne');
      expect(res.presentForms[GermanPronoun.du], 'lernst');
      expect(res.presentForms[GermanPronoun.erSieEs], 'lernt');
      expect(res.presentForms[GermanPronoun.wir], 'lernen');
      expect(res.presentForms[GermanPronoun.ihr], 'lernt');
      expect(res.presentForms[GermanPronoun.sieSie], 'lernen');
      expect(res.pastParticiple, 'gelernt');
      expect(res.auxiliary, 'haben');
    });

    test('Stem vowel changes (Vokalwechsel): e->i, e->ie, a->ä', () {
      final helfen = GermanVerbConjugator.conjugate('helfen');
      expect(helfen.presentForms[GermanPronoun.du], 'hilfst');
      expect(helfen.presentForms[GermanPronoun.erSieEs], 'hilft');
      expect(helfen.pastParticiple, 'geholfen');

      final sehen = GermanVerbConjugator.conjugate('sehen');
      expect(sehen.presentForms[GermanPronoun.du], 'siehst');
      expect(sehen.presentForms[GermanPronoun.erSieEs], 'sieht');
      expect(sehen.pastParticiple, 'gesehen');

      final fahren = GermanVerbConjugator.conjugate('fahren');
      expect(fahren.presentForms[GermanPronoun.du], 'fährst');
      expect(fahren.presentForms[GermanPronoun.erSieEs], 'fährt');
      expect(fahren.auxiliary, 'sein'); // movement verb
      expect(fahren.pastParticiple, 'gefahren');
    });

    test('Auxiliary and modal verbs', () {
      final sein = GermanVerbConjugator.conjugate('sein');
      expect(sein.presentForms[GermanPronoun.ich], 'bin');
      expect(sein.presentForms[GermanPronoun.du], 'bist');
      expect(sein.presentForms[GermanPronoun.erSieEs], 'ist');
      expect(sein.presentForms[GermanPronoun.wir], 'sind');
      expect(sein.pastParticiple, 'gewesen');

      final koennen = GermanVerbConjugator.conjugate('können');
      expect(koennen.presentForms[GermanPronoun.ich], 'kann');
      expect(koennen.presentForms[GermanPronoun.erSieEs], 'kann');
    });

    test('Separable verbs: aufstehen', () {
      final res = GermanVerbConjugator.conjugate('aufstehen');
      expect(res.isSeparable, isTrue);
      expect(res.prefix, 'auf');
      expect(res.baseVerb, 'stehen');
      expect(res.presentForms[GermanPronoun.ich], 'aufstehe');
      expect(res.mainClauseV2Forms[GermanPronoun.ich], 'stehe ... auf');
      expect(res.pastParticiple, 'aufgestanden');
      expect(res.auxiliary, 'sein');
    });
  });
}
