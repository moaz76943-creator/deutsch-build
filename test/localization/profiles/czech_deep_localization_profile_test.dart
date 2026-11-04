import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/czech_deep_localization_profile.dart';

void main() {
  group('CzechDeepLocalizationProfile Tests', () {
    const profile = CzechDeepLocalizationProfile();

    test('Linguistic properties correctly model West Slavic Czech standard', () {
      expect(profile.languageName, equals('Czech'));
      expect(profile.iso6391, equals('cs'));
      expect(profile.iso6392, equals('ces'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('West Slavic'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasNativeGermanZSound, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.specialCharacters, contains('ř'));
      expect(profile.specialCharacters, contains('š'));
      expect(profile.specialCharacters, contains('č'));
      expect(profile.genderEquivalenceMap.length, equals(3));
    });

    test('Case system alignment maps 7 Czech cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Nominativ'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Akuzativ'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Instrumentál'), contains('mit'));
    });

    test('Phonetic bridge identifies native match for letter C to German Z and vowel length', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Š')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Vowel Quantity')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('dobrý den / selam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halál'));
      expect(profile.culturalIslamicLexicon.keys, contains('modlitba / namáz'));
      expect(profile.coreA1Vocabulary['Děkuji mnohokrát'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
