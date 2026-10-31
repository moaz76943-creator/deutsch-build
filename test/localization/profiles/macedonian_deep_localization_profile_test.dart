import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/macedonian_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('MacedonianDeepLocalizationProfile Tests', () {
    const profile = MacedonianDeepLocalizationProfile();

    test('Linguistic properties correctly model South Slavic Macedonian standard', () {
      expect(profile.languageName, equals('Macedonian'));
      expect(profile.iso6391, equals('mk'));
      expect(profile.iso6392or3, equals('mkd'));
      expect(profile.typology, equals(TypologicalClassification.isolatingAnalytic));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.specialCharacters, contains('Ѓ'));
      expect(profile.specialCharacters, contains('Ѕ'));
      expect(profile.specialCharacters, contains('Џ'));
    });

    test('3-way spatial article bridge and analytical cases are verified', () {
      expect(profile.threeWayArticleBridge, containsKey(contains('3-Way Spatial Article')));
      expect(profile.analyticalPrepositionalBridge.length, equals(5));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('здраво / добар ден / селам'));
      expect(profile.culturalIslamicLexicon, containsKey('халал'));
      expect(profile.culturalIslamicLexicon, containsKey('џамија'));
      expect(profile.coreA1Vocabulary['Многу благодарам'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
