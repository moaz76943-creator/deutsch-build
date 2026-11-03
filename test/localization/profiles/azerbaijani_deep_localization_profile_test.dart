import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/azerbaijani_deep_localization_profile.dart';

void main() {
  group('AzerbaijaniDeepLocalizationProfile Tests', () {
    const profile = AzerbaijaniDeepLocalizationProfile();

    test('Linguistic attributes correctly model Oghuz Turkic system', () {
      expect(profile.languageName, equals('Azerbaijani'));
      expect(profile.iso6391, equals('az'));
      expect(profile.iso6392, equals('aze'));
      expect(profile.languageFamily, equals('Turkic'));
      expect(profile.branch, equals('Oghuz'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasVowelHarmony, isTrue);
      expect(profile.hasGrammaticalGender, isFalse);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('ə'));
      expect(profile.specialCharacters, contains('ö'));
      expect(profile.specialCharacters, contains('ü'));
    });

    test('Native German umlaut capability is recognized', () {
      expect(profile.hasNativeGermanUmlauts(), isTrue);
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('ö /ø/')).having((entry) => entry.value, 'value', contains('1:1'))));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ş')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', equals('ch /x/')).having((entry) => entry.value, 'value', contains('x'))));
    });

    test('6-case system maps precisely to German case-preposition network', () {
      expect(profile.caseSystemAlignment.length, equals(6));
      expect(profile.getGermanCaseEquivalent('Təsirlik'), contains('Akkusativ'));
      expect(profile.getGermanCaseEquivalent('Yiyəlik'), contains('Genitiv'));
      expect(profile.getGermanCaseEquivalent('Yönlük'), contains('Dativ'));
      expect(profile.getGermanCaseEquivalent('Yerlik'), contains('Dativ'));
      expect(profile.getGermanCaseEquivalent('Çıxış'), contains('Dativ'));
    });

    test('Islamic cultural lexicon and A1 vocabulary are verified', () {
      expect(profile.culturalIslamicLexicon.keys, contains('salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('təşəkkür'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('ədalət'));
      expect(profile.coreA1Vocabulary['Salam'], equals('Hallo / Guten Tag'));
      expect(profile.coreA1Vocabulary['Bəli'], equals('Ja'));
      expect(profile.coreA1Vocabulary['Xeyr'], equals('Nein'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
