import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/chechen_deep_localization_profile.dart';

void main() {
  group('ChechenDeepLocalizationProfile Tests', () {
    const profile = ChechenDeepLocalizationProfile();

    test('Linguistic properties correctly model Nakh Chechen standard', () {
      expect(profile.languageName, equals('Chechen'));
      expect(profile.iso6391, equals('ce'));
      expect(profile.iso6392, equals('che'));
      expect(profile.languageFamily, equals('Northeast Caucasian'));
      expect(profile.branch, equals('Nakh'));
      expect(profile.hasErgativeAlignment, isTrue);
      expect(profile.hasNounClasses, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('Ӏ'));
      expect(profile.specialCharacters, contains('оь'));
      expect(profile.specialCharacters, contains('уь'));
    });

    test('Case system alignment maps 8 cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(8));
      expect(profile.getGermanCaseBridge('Цӏерниг'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Доланиг'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Лург'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Коьчалниг'), contains('mit'));
      expect(profile.getGermanCaseBridge('Хотталург'), contains('zu'));
    });

    test('Phonetic bridge identifies native match for letter Ц to German Z and umlauts', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Ш')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Umlaut Fronting')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('марша догӏийла / салам'));
      expect(profile.culturalIslamicLexicon.keys, contains('хьанал'));
      expect(profile.culturalIslamicLexicon.keys, contains('ламаз'));
      expect(profile.culturalIslamicLexicon.keys, contains('маьждиг'));
      expect(profile.coreA1Vocabulary['Дела реза хуьлда / Баркалла'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
