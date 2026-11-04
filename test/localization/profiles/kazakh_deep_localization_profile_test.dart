import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/kazakh_deep_localization_profile.dart';

void main() {
  group('KazakhDeepLocalizationProfile Tests', () {
    const profile = KazakhDeepLocalizationProfile();

    test('Linguistic and typological metadata conform to Kipchak Kazakh standard', () {
      expect(profile.languageName, equals('Kazakh'));
      expect(profile.iso6391, equals('kk'));
      expect(profile.iso6392, equals('kaz'));
      expect(profile.languageFamily, equals('Turkic'));
      expect(profile.branch, contains('Kipchak'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasVowelHarmony, isTrue);
      expect(profile.hasGrammaticalGender, isFalse);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.hasNativeGermanUmlauts(), isTrue);
    });

    test('7-case system maps precisely to German case-preposition network', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Ataw'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Tabıs'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('İlik'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Barıs'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Kömektes'), contains('mit'));
    });

    test('Phonetic bridge establishes native umlaut alignment', () {
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('ö /ø/')).having((entry) => entry.value, 'value', contains('100% Native'))));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ş')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('ach-Laut')).having((entry) => entry.value, 'value', contains('x'))));
    });

    test('Islamic cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('sälem'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('namaz'));
      expect(profile.coreA1Vocabulary['Ülken raqmet'], equals('Vielen Dank'));
      expect(profile.coreA1Vocabulary['Iä'], equals('Ja'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
