import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/tigrinya_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('TigrinyaDeepLocalizationProfile Tests', () {
    const profile = TigrinyaDeepLocalizationProfile();

    test('Linguistic properties correctly model South Semitic Tigrinya standard', () {
      expect(profile.languageName, equals('Tigrinya'));
      expect(profile.iso6391, equals('ti'));
      expect(profile.iso6392or3, equals('tir'));
      expect(profile.typology, equals(TypologicalClassification.fusionalInflected));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.sov));
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.primaryScript, contains('Ge\'ez'));
      expect(profile.ejectiveConsonants, contains('ቀ'));
      expect(profile.ejectiveConsonants, contains('ጠ'));
    });

    test('Semitic cognates link Tigrinya directly to Arabic lexical roots', () {
      expect(profile.semiticCognateBridges, containsPair(contains('selam'), contains('Salam')));
      expect(profile.semiticCognateBridges, containsPair(contains('bēt'), contains('Bayt')));
      expect(profile.semiticCognateBridges, containsPair(contains('dem'), contains('Dam')));
    });

    test('Case prefix alignment maps to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Nominativ'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Akkusativ'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Instrumentalis'), contains('mit'));
      expect(profile.getGermanCaseBridge('Ablativ'), contains('aus'));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('ሰላም / ከመይ ኣለኻ/ኺ'));
      expect(profile.culturalIslamicLexicon, containsKey('ሀላል'));
      expect(profile.culturalIslamicLexicon, containsKey('መስጊድ'));
      expect(profile.coreA1Vocabulary['የቐንየለይ ብጣዕሚ'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
