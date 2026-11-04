import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/telugu_deep_localization_profile.dart';

void main() {
  group('TeluguDeepLocalizationProfile Tests', () {
    const profile = TeluguDeepLocalizationProfile();

    test('Linguistic properties correctly model South-Central Dravidian Telugu', () {
      expect(profile.languageName, equals('Telugu'));
      expect(profile.iso6391, equals('te'));
      expect(profile.iso6392, equals('tel'));
      expect(profile.languageFamily, equals('Dravidian'));
      expect(profile.branch, contains('South-Central Dravidian'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasVowelHarmonicSuffixes, isTrue);
      expect(profile.wordOrder, equals('SOV'));
    });

    test('Vibhakti case system alignment maps to German case structure', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Prathama'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Dvitiya'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Tritiya'), contains('mit'));
      expect(profile.getGermanCaseBridge('Panchami'), contains('aus'));
    });

    test('Phonetic bridge accurately assists German sound acquisition', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('శ')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('త్+స్')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Vowel Coda')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('నమస్కారం / సలాం'));
      expect(profile.culturalIslamicLexicon.keys, contains('హలాల్'));
      expect(profile.culturalIslamicLexicon.keys, contains('నమాజ్ / ప్రార్థన'));
      expect(profile.coreA1Vocabulary['చాలా ధన్యవాదాలు'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
