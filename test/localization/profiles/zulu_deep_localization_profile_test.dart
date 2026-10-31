import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/zulu_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('ZuluDeepLocalizationProfile Tests', () {
    const profile = ZuluDeepLocalizationProfile();

    test('Linguistic properties correctly model Southern Bantu Zulu standard', () {
      expect(profile.languageName, equals('Zulu'));
      expect(profile.iso6391, equals('zu'));
      expect(profile.iso6392or3, equals('zul'));
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
      expect(profile.culturalIslamicLexicon, containsKey('sawubona / sanibonani / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('i-halal'));
      expect(profile.culturalIslamicLexicon, containsKey('i-mosque / i-masjid'));
      expect(profile.coreA1Vocabulary['Ngiyabonga kakhulu'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
