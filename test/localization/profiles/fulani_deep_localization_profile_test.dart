import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/fulani_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('FulaniDeepLocalizationProfile Tests', () {
    const profile = FulaniDeepLocalizationProfile();

    test('Linguistic properties correctly model Senegambian Fulani standard', () {
      expect(profile.languageName, equals('Fulani'));
      expect(profile.iso6391, equals('ff'));
      expect(profile.iso6392or3, equals('ful'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.nounClassCount, greaterThanOrEqualTo(20));
    });

    test('Noun class advantage bridges seamlessly to German gender system', () {
      expect(profile.nounClassAdvantageBridge.keys, contains(contains('25-Noun-Class')));
      expect(profile.nounClassAdvantageBridge.keys, contains(contains('Consonant Mutation')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('C / c')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('jam / no wa\'i / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('deftere'));
      expect(profile.coreA1Vocabulary['A jaaraama no feewi'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
