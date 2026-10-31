import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/kinyarwanda_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('KinyarwandaDeepLocalizationProfile Tests', () {
    const profile = KinyarwandaDeepLocalizationProfile();

    test('Linguistic properties correctly model Rwanda-Rundi Bantu standard', () {
      expect(profile.languageName, equals('Kinyarwanda'));
      expect(profile.iso6391, equals('rw'));
      expect(profile.iso6392or3, equals('kin'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isTrue);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.nounClassCount, equals(16));
    });

    test('16-noun-class augment definiteness bridge is established', () {
      expect(profile.augmentNounClassBridge, containsKey(contains('16-Noun-Class')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Sh')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('C / c')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('muraho / salamu alaykum'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('umusigiti'));
      expect(profile.coreA1Vocabulary['Murakoze cyane'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
