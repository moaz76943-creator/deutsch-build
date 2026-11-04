import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/kurdish_sorani_deep_localization_profile.dart';

void main() {
  group('KurdishSoraniDeepLocalizationProfile Tests', () {
    const profile = KurdishSoraniDeepLocalizationProfile();

    test('Linguistic properties correctly model Sorani Kurdish standard', () {
      expect(profile.languageName, equals('Kurdish Sorani'));
      expect(profile.iso6391, equals('ku'));
      expect(profile.iso6393, equals('ckb'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Northwestern Iranian'));
      expect(profile.writingDirection, equals('rtl'));
      expect(profile.hasPronominalCliticErgativity, isTrue);
      expect(profile.hasIzafeConstruct, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('ێ'));
      expect(profile.specialCharacters, contains('ۆ'));
      expect(profile.specialCharacters, contains('ڵ'));
      expect(profile.specialCharacters, contains('ڕ'));
    });

    test('Case and preposition alignment maps to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Subject'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('لەگەڵ'), contains('mit'));
      expect(profile.getGermanCaseBridge('بۆ'), contains('zu'));
      expect(profile.getGermanCaseBridge('Izafe'), contains('Genitiv'));
    });

    test('Phonetic bridge identifies native matches for consonants', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ش')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('چ')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('ach-Laut')).having((entry) => entry.value, 'value', contains('خ'))));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('ت+س')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('سڵاو / سڵاوی خواتان لێ بێت'));
      expect(profile.culturalIslamicLexicon.keys, contains('حەڵاڵ'));
      expect(profile.culturalIslamicLexicon.keys, contains('نوێژ / سەڵات'));
      expect(profile.culturalIslamicLexicon.keys, contains('مزگەوت'));
      expect(profile.coreA1Vocabulary['زۆر سوپاس'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
