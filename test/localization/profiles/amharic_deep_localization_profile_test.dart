import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/amharic_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('AmharicDeepLocalizationProfile Tests', () {
    const profile = AmharicDeepLocalizationProfile();

    test('Linguistic properties correctly model South Semitic Amharic standard', () {
      expect(profile.languageName, equals('Amharic'));
      expect(profile.iso6391, equals('am'));
      expect(profile.iso6392or3, equals('amh'));
      expect(profile.typology, equals(TypologicalClassification.fusionalInflected));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.sov));
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.primaryScript, contains('Ge\'ez'));
      expect(profile.ejectiveConsonants, contains('ቀ'));
      expect(profile.ejectiveConsonants, contains('ጠ'));
    });

    test('Semitic cognates link Amharic and Arabic lexical roots', () {
      expect(profile.semiticCognateBridges, containsPair(contains('selam'), contains('Salam')));
      expect(profile.semiticCognateBridges, containsPair(contains('bēt'), contains('Bayt')));
      expect(profile.semiticCognateBridges, containsPair(contains('dem'), contains('Blut')));
    });

    test('Case and preposition alignment maps to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(6));
      expect(profile.getGermanCaseBridge('Nominativ'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Akkusativ'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Instrumentalis'), contains('mit'));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('ሰላም / እንዴት ነዎት'));
      expect(profile.culturalIslamicLexicon, containsKey('ሀላል'));
      expect(profile.culturalIslamicLexicon, containsKey('መስጊድ'));
      expect(profile.coreA1Vocabulary['በጣም አመሰግናለሁ'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
