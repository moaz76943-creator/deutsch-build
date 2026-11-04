import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/wolof_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('WolofDeepLocalizationProfile Tests', () {
    const profile = WolofDeepLocalizationProfile();

    test('Linguistic properties correctly model Senegambian Wolof standard', () {
      expect(profile.languageName, equals('Wolof'));
      expect(profile.iso6391, equals('wo'));
      expect(profile.iso6392or3, equals('wol'));
      expect(profile.typology, equals(TypologicalClassification.isolatingAnalytic));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isFalse);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.nounClassCount, equals(8));
    });

    test('Spatial determiner and phonetic bridges are established', () {
      expect(profile.spatialDeterminerBridge.keys, contains(contains('Spatial Determiner')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('C / c')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('ach-Laut')).having((entry) => entry.value, 'value', contains('X / x'))));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('salaam alaykum / na nga def'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('jàkka / jumaa'));
      expect(profile.coreA1Vocabulary['Jërëjëf lool'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
