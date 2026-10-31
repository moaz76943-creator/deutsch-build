import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/french_deep_localization_profile.dart';

void main() {
  group('FrenchDeepLocalizationProfile Tests', () {
    const profile = FrenchDeepLocalizationProfile();

    test('Linguistic properties correctly model Gallo-Romance French standard', () {
      expect(profile.languageName, equals('French'));
      expect(profile.iso6391, equals('fr'));
      expect(profile.iso6392, equals('fra'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Romance'));
      expect(profile.hasTwoGenders, isTrue);
      expect(profile.hasUvularR, isTrue);
      expect(profile.hasNativeGermanUmlauts, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.specialCharacters, contains('ç'));
      expect(profile.specialCharacters, contains('é'));
    });

    test('Case and preposition alignment maps to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(6));
      expect(profile.getGermanCaseBridge('Nominativ'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Akkusativ'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Instrumentalis'), contains('mit'));
    });

    test('Phonetic bridge identifies 100% native matches for uvular R, U, and EU', () {
      expect(profile.germanPhoneticBridges, containsPair(contains('Uvular R'), contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ü /y/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ö /ø/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Ch')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Aspirated H'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('bonjour / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('mosquée'));
      expect(profile.coreA1Vocabulary['Merci beaucoup'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
