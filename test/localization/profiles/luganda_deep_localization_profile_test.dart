import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/luganda_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('LugandaDeepLocalizationProfile Tests', () {
    const profile = LugandaDeepLocalizationProfile();

    test('Linguistic properties correctly model Great Lakes Bantu Luganda standard', () {
      expect(profile.languageName, equals('Luganda'));
      expect(profile.iso6391, equals('lg'));
      expect(profile.iso6392or3, equals('lug'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isTrue);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.nounClassCount, equals(10));
    });

    test('Initial augment definiteness bridge is established', () {
      expect(profile.initialAugmentArticleBridge.keys, contains(contains('Augment Pre-Prefix')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('C / c')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('ki kati / oli otya / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('omuzikiti'));
      expect(profile.coreA1Vocabulary['Weebale nnyo'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
