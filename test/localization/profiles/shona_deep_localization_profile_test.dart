import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/shona_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('ShonaDeepLocalizationProfile Tests', () {
    const profile = ShonaDeepLocalizationProfile();

    test('Linguistic properties correctly model Southern Bantu Shona standard', () {
      expect(profile.languageName, equals('Shona'));
      expect(profile.iso6391, equals('sn'));
      expect(profile.iso6392or3, equals('sna'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.nounClassCount, greaterThanOrEqualTo(20));
      expect(profile.whistlingSibilants.length, equals(4));
    });

    test('20+ noun class concord and whistling sibilants are verified', () {
      expect(profile.nounClassConcordBridge, containsKey(contains('20+ Noun-Class')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Sh')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Ch')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('Ts')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('mhoro / kwaziwai / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('masikiti'));
      expect(profile.coreA1Vocabulary['Maita basa zvikuru'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
