import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/turkmen_deep_localization_profile.dart';

void main() {
  group('TurkmenDeepLocalizationProfile Tests', () {
    const profile = TurkmenDeepLocalizationProfile();

    test('Linguistic properties correctly model East Oghuz Turkmen', () {
      expect(profile.languageName, equals('Turkmen'));
      expect(profile.iso6391, equals('tk'));
      expect(profile.iso6392, equals('tuk'));
      expect(profile.languageFamily, equals('Turkic'));
      expect(profile.branch, contains('East Oghuz'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasPrimaryVowelLength, isTrue);
      expect(profile.hasVowelHarmony, isTrue);
      expect(profile.hasNativeGermanUmlauts(), isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('ň'));
      expect(profile.specialCharacters, contains('ý'));
    });

    test('Case system alignment maps 6 cases to German prepositions & declensions', () {
      expect(profile.caseSystemAlignment.length, equals(6));
      expect(profile.getGermanCaseBridge('Baş'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Ýeňiş'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Eýelik'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Ýöneliş'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Çykyş'), contains('aus'));
    });

    test('Phonetic bridge identifies native umlaut and vowel length alignment', () {
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('ö /ø/')).having((entry) => entry.value, 'value', contains('100% Native'))));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ş')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Vowel Length')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('salam / essalamu aleýkum'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('namaz'));
      expect(profile.coreA1Vocabulary['Köp sag boluň'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
