import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/marathi_deep_localization_profile.dart';

void main() {
  group('MarathiDeepLocalizationProfile Tests', () {
    const profile = MarathiDeepLocalizationProfile();

    test('Linguistic properties correctly highlight 3-gender & native /ts/ sound', () {
      expect(profile.languageName, equals('Marathi'));
      expect(profile.iso6391, equals('mr'));
      expect(profile.iso6392, equals('mar'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Indo-Aryan'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasNativeAffricateTS, isTrue);
      expect(profile.hasNativeGermanZSound(), isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.genderEquivalenceMap.length, equals(3));
    });

    test('Phonetic bridge identifies Marathi dental affricate for German Z', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('Native 1:1')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('श')));
    });

    test('Case system alignment links Marathi traditional vibhakti to German cases', () {
      expect(profile.caseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Prathama')).having((entry) => entry.value, 'value', contains('Nominativ'))));
      expect(profile.caseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Shashthi')).having((entry) => entry.value, 'value', contains('Genitiv'))));
      expect(profile.caseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Saptami')).having((entry) => entry.value, 'value', contains('in'))));
      expect(profile.caseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Tritiya')).having((entry) => entry.value, 'value', contains('mit'))));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('सलाम'));
      expect(profile.culturalIslamicLexicon.keys, contains('हलाल'));
      expect(profile.culturalIslamicLexicon.keys, contains('नमाज'));
      expect(profile.coreA1Vocabulary['खूप खूप धन्यवाद'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
