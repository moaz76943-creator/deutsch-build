import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/polish_deep_localization_profile.dart';

void main() {
  group('PolishDeepLocalizationProfile Tests', () {
    const profile = PolishDeepLocalizationProfile();

    test('Linguistic properties correctly model West Slavic Polish standard', () {
      expect(profile.languageName, equals('Polish'));
      expect(profile.iso6391, equals('pl'));
      expect(profile.iso6392, equals('pol'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('West Slavic'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasNativeGermanZSound, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.specialCharacters, contains('ą'));
      expect(profile.specialCharacters, contains('ę'));
      expect(profile.specialCharacters, contains('ł'));
      expect(profile.specialCharacters, contains('ż'));
    });

    test('Case system alignment maps 7 cases to German declension structure', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Mianownik'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Dopełniacz'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Celownik'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Biernik'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Narzędnik'), contains('mit'));
    });

    test('Shared cognates and phonetic bridges accurately assist German acquisition', () {
      expect(profile.sharedCognateBridges, containsPair('szynka', contains('Schinken')));
      expect(profile.sharedCognateBridges, containsPair('burmistrz', contains('Bürgermeister')));
      expect(profile.sharedCognateBridges, containsPair('ratusz', contains('Rathaus')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Sz')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('dzień dobry / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('modlitwa / namaz'));
      expect(profile.coreA1Vocabulary['Dziękuję bardzo'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
