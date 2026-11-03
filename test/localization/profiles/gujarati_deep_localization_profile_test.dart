import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/gujarati_deep_localization_profile.dart';

void main() {
  group('GujaratiDeepLocalizationProfile Tests', () {
    const profile = GujaratiDeepLocalizationProfile();

    test('Linguistic properties correctly highlight 3-gender Indo-Aryan system', () {
      expect(profile.languageName, equals('Gujarati'));
      expect(profile.iso6391, equals('gu'));
      expect(profile.iso6392, equals('guj'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Indo-Aryan'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.matchesGermanThreeGenders(), isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.genderEquivalenceMap.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Puling')).having((entry) => entry.value, 'value', contains('Maskulinum'))));
      expect(profile.genderEquivalenceMap.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Striling')).having((entry) => entry.value, 'value', contains('Femininum'))));
      expect(profile.genderEquivalenceMap.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Napunsakling')).having((entry) => entry.value, 'value', contains('Neutrum'))));
    });

    test('Phonetic bridge accurately assists German sound acquisition', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('શ')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('ત્સ')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('3-Gender')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Case system alignment links postpositions to German cases', () {
      expect(profile.caseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Direct')).having((entry) => entry.value, 'value', contains('Nominativ'))));
      expect(profile.caseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Genitive')).having((entry) => entry.value, 'value', contains('Genitiv'))));
      expect(profile.caseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Locative')).having((entry) => entry.value, 'value', contains('in'))));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('સલામ'));
      expect(profile.culturalIslamicLexicon.keys, contains('હલાલ'));
      expect(profile.culturalIslamicLexicon.keys, contains('નમાઝ'));
      expect(profile.coreA1Vocabulary['ખૂબ ખૂબ આભાર'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
