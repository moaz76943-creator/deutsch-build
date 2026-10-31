import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/slovak_deep_localization_profile.dart';

void main() {
  group('SlovakDeepLocalizationProfile Tests', () {
    const profile = SlovakDeepLocalizationProfile();

    test('Linguistic properties correctly model West Slavic Slovak standard', () {
      expect(profile.languageName, equals('Slovak'));
      expect(profile.iso6391, equals('sk'));
      expect(profile.iso6392, equals('slk'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('West Slavic'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasNativeGermanZSound, isTrue);
      expect(profile.hasNativeGermanASound, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.specialCharacters, contains('ä'));
      expect(profile.specialCharacters, contains('ô'));
      expect(profile.specialCharacters, contains('č'));
      expect(profile.specialCharacters, contains('š'));
    });

    test('Case system alignment maps 6 Slovak cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(6));
      expect(profile.getGermanCaseBridge('Nominatív'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Genitív'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Datív'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Akuzatív'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Inštrumentál'), contains('mit'));
    });

    test('Phonetic bridge identifies native match for letter C to Z and Ä to Ä', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ä /ɛ/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Š')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('dobrý deň / selam'));
      expect(profile.culturalIslamicLexicon, containsKey('halál'));
      expect(profile.culturalIslamicLexicon, containsKey('modlitba / namáz'));
      expect(profile.coreA1Vocabulary['Ďakujem pekne'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
