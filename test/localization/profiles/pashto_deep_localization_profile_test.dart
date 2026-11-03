import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/pashto_deep_localization_profile.dart';

void main() {
  group('PashtoDeepLocalizationProfile Tests', () {
    const profile = PashtoDeepLocalizationProfile();

    test('Linguistic and typological metadata conform to Eastern Iranian system', () {
      expect(profile.languageName, equals('Pashto'));
      expect(profile.iso6391, equals('ps'));
      expect(profile.iso6392, equals('pus'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, equals('Eastern Iranian'));
      expect(profile.writingDirection, equals('rtl'));
      expect(profile.hasSplitErgativity, isTrue);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('ښ'));
      expect(profile.specialCharacters, contains('څ'));
      expect(profile.specialCharacters, contains('ځ'));
    });

    test('Affricate bridge identifies Pashto څ as perfect match for German Z', () {
      expect(profile.hasAffricateBridgeForGermanZ(), isTrue);
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('څ')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ش')));
    });

    test('Case system and circumposition alignment are accurately defined', () {
      expect(profile.getCaseBridge('Direct'), contains('Nominativ'));
      expect(profile.getCaseBridge('Oblique'), contains('Akkusativ'));
      expect(profile.caseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Circumpositions')).having((entry) => entry.value, 'value', contains('Dativ'))));
    });

    test('Islamic cultural lexicon and core vocabulary are verified', () {
      expect(profile.culturalIslamicLexicon.keys, contains('سلام'));
      expect(profile.culturalIslamicLexicon.keys, contains('حلال'));
      expect(profile.culturalIslamicLexicon.keys, contains('لمونځ'));
      expect(profile.coreA1Vocabulary['ډېره مننه'], equals('Vielen Dank'));
      expect(profile.coreA1Vocabulary['هو'], equals('Ja'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
