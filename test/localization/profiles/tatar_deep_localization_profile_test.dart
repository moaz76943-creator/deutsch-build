import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/tatar_deep_localization_profile.dart';

void main() {
  group('TatarDeepLocalizationProfile Tests', () {
    const profile = TatarDeepLocalizationProfile();

    test('Linguistic properties correctly model Kipchak-Bulgar Tatar standard', () {
      expect(profile.languageName, equals('Tatar'));
      expect(profile.iso6391, equals('tt'));
      expect(profile.iso6392, equals('tat'));
      expect(profile.languageFamily, equals('Turkic'));
      expect(profile.branch, contains('Kipchak-Bulgar'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasAllThreeGermanUmlauts, isTrue);
      expect(profile.hasAllThreeGermanUmlautGraphemes(), isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('Ә'));
      expect(profile.specialCharacters, contains('Ө'));
      expect(profile.specialCharacters, contains('Ү'));
      expect(profile.specialCharacters, contains('Җ'));
      expect(profile.specialCharacters, contains('Ң'));
      expect(profile.specialCharacters, contains('Һ'));
    });

    test('Case system alignment maps 6 cases to German prepositions & declensions', () {
      expect(profile.caseSystemAlignment.length, equals(6));
      expect(profile.getGermanCaseBridge('Төп'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Төшем'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Иялек'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Юнәлеш'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Чыгыш'), contains('aus'));
    });

    test('Phonetic bridge identifies native triple umlaut alignment', () {
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Triple Umlaut')).having((entry) => entry.value, 'value', contains('100% Native Triad'))));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ш')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('ach-Laut')).having((entry) => entry.value, 'value', contains('х'))));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('сәлам / әссәламегаләйкем'));
      expect(profile.culturalIslamicLexicon.keys, contains('хәләл'));
      expect(profile.culturalIslamicLexicon.keys, contains('намаз'));
      expect(profile.coreA1Vocabulary['Зур рәхмәт'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
