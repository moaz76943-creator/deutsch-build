import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/latvian_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('LatvianDeepLocalizationProfile Tests', () {
    const profile = LatvianDeepLocalizationProfile();

    test('Linguistic properties correctly model Baltic Latvian standard', () {
      expect(profile.languageName, equals('Latvian'));
      expect(profile.iso6391, equals('lv'));
      expect(profile.iso6392or3, equals('lav'));
      expect(profile.typology, equals(TypologicalClassification.fusionalInflected));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isFalse);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.specialCharacters, contains('ā'));
      expect(profile.specialCharacters, contains('š'));
      expect(profile.specialCharacters, contains('č'));
    });

    test('6-case system alignment maps to German declensions', () {
      expect(profile.sixCaseSystemAlignment.length, equals(6));
      expect(profile.sixCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Nominatīvs')).having((entry) => entry.value, 'value', contains('Nominativ'))));
      expect(profile.sixCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Ģenitīvs')).having((entry) => entry.value, 'value', contains('Genitiv'))));
      expect(profile.sixCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Datīvs')).having((entry) => entry.value, 'value', contains('Dativ'))));
      expect(profile.sixCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Akuzatīvs')).having((entry) => entry.value, 'value', contains('Akkusativ'))));
    });

    test('Phonetic bridge identifies 100% native matches for C and Š', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Initial Stress')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('sveiki / labdien / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('mošeja'));
      expect(profile.coreA1Vocabulary['Liels paldies'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
