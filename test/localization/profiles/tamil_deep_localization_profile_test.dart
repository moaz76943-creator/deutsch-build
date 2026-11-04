import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/tamil_deep_localization_profile.dart';

void main() {
  group('TamilDeepLocalizationProfile Tests', () {
    const profile = TamilDeepLocalizationProfile();

    test('Linguistic properties correctly model classical Dravidian Tamil', () {
      expect(profile.languageName, equals('Tamil'));
      expect(profile.iso6391, equals('ta'));
      expect(profile.iso6392, equals('tam'));
      expect(profile.languageFamily, equals('Dravidian'));
      expect(profile.branch, contains('Southern Dravidian'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasGrammaticalGenderInArticles, isFalse);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('ழ'));
      expect(profile.specialCharacters, contains('ள'));
      expect(profile.specialCharacters, contains('ஃ'));
    });

    test('Case system alignment accurately maps Veṟṟumai cases to German', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Mudhal'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Iraṇḍām'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Nāngām'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Aindhām'), contains('aus'));
    });

    test('Phonetic bridge assists German sound acquisition and cluster mitigation', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ஷ')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('த்+ஸ்')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Cluster Mitigation')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('வணக்கம் / ஸலாம்'));
      expect(profile.culturalIslamicLexicon.keys, contains('ஹலால்'));
      expect(profile.culturalIslamicLexicon.keys, contains('தொழுகை / நமாஸ்'));
      expect(profile.coreA1Vocabulary['மிக்க நன்றி'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
