import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/macedonian_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

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
      expect(profile.threeWayArticleBridge.keys, contains(contains('3-Way Spatial Article')));
      expect(profile.analyticalPrepositionalBridge.length, equals(5));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('здраво / добар ден / селам'));
      expect(profile.culturalIslamicLexicon.keys, contains('халал'));
      expect(profile.culturalIslamicLexicon.keys, contains('џамија'));
      expect(profile.coreA1Vocabulary['Многу благодарам'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
