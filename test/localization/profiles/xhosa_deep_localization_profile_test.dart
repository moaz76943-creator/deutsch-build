import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/xhosa_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('XhosaDeepLocalizationProfile Tests', () {
    const profile = XhosaDeepLocalizationProfile();

    test('Linguistic properties correctly model Southern Bantu Xhosa standard', () {
      expect(profile.languageName, equals('Xhosa'));
      expect(profile.iso6391, equals('xh'));
      expect(profile.iso6392or3, equals('xho'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.nounClassCount, equals(15));
      expect(profile.clickConsonants.length, equals(3));
    });

    test('15 noun class concord and click consonant traits are verified', () {
      expect(profile.nounClassConcordBridge, containsKey(contains('15-Noun-Class')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Sh')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Tsh')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('molo / molweni / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('i-halal'));
      expect(profile.culturalIslamicLexicon, containsKey('imosque / imasjid'));
      expect(profile.coreA1Vocabulary['Enkosi kakhulu'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
