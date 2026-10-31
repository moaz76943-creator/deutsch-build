import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/slovenian_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

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
      expect(profile.dualNumberBridge, containsKey(contains('Dvojina')));
      expect(profile.sixCaseSystemAlignment.length, equals(6));
      expect(profile.sixCaseSystemAlignment, containsPair(contains('Imenovalnik'), contains('Nominativ')));
      expect(profile.sixCaseSystemAlignment, containsPair(contains('Rodilnik'), contains('Genitiv')));
      expect(profile.sixCaseSystemAlignment, containsPair(contains('Dajalnik'), contains('Dativ')));
    });

    test('Phonetic bridge identifies 100% native matches for C and Š', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('100% Native Identity')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('dober dan / živjo / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('mošeja / džamija'));
      expect(profile.coreA1Vocabulary['Hvala lepa'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
