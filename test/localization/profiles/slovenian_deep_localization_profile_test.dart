import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/slovenian_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('SlovenianDeepLocalizationProfile Tests', () {
    const profile = SlovenianDeepLocalizationProfile();

    test('Linguistic properties correctly model South Slavic Slovenian standard', () {
      expect(profile.languageName, equals('Slovenian'));
      expect(profile.iso6391, equals('sl'));
      expect(profile.iso6392or3, equals('slv'));
      expect(profile.typology, equals(TypologicalClassification.fusionalInflected));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasDualGrammaticalNumber, isTrue);
    });

    test('Dual number bridge and 6-case alignment are established', () {
      expect(profile.dualNumberBridge.keys, contains(contains('Dvojina')));
      expect(profile.sixCaseSystemAlignment.length, equals(6));
      expect(profile.sixCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Imenovalnik')).having((entry) => entry.value, 'value', contains('Nominativ'))));
      expect(profile.sixCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Rodilnik')).having((entry) => entry.value, 'value', contains('Genitiv'))));
      expect(profile.sixCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Dajalnik')).having((entry) => entry.value, 'value', contains('Dativ'))));
    });

    test('Phonetic bridge identifies 100% native matches for C and Š', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('100% Native Identity')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('dober dan / živjo / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('mošeja / džamija'));
      expect(profile.coreA1Vocabulary['Hvala lepa'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
