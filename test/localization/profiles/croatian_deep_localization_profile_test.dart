import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/croatian_deep_localization_profile.dart';

void main() {
  group('CroatianDeepLocalizationProfile Tests', () {
    const profile = CroatianDeepLocalizationProfile();

    test('Linguistic properties correctly model South Slavic Croatian standard', () {
      expect(profile.languageName, equals('Croatian'));
      expect(profile.iso6391, equals('hr'));
      expect(profile.iso6392, equals('hrv'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('South Slavic'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasNativeGermanZSound, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.specialCharacters, contains('č'));
      expect(profile.specialCharacters, contains('š'));
      expect(profile.specialCharacters, contains('ž'));
      expect(profile.genderEquivalenceMap.length, equals(3));
    });

    test('Case system alignment maps 7 cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Nominativ'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Akuzativ'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Instrumental'), contains('mit'));
    });

    test('Phonetic bridge identifies native match for letter C to German Z', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Š')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Puristic Neologism')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('dobar dan / selam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('džamija'));
      expect(profile.coreA1Vocabulary['Hvala lijepa'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
