import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/bambara_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('BambaraDeepLocalizationProfile Tests', () {
    const profile = BambaraDeepLocalizationProfile();

    test('Linguistic properties correctly model Mande Bambara standard', () {
      expect(profile.languageName, equals('Bambara'));
      expect(profile.iso6391, equals('bm'));
      expect(profile.iso6392or3, equals('bam'));
      expect(profile.typology, equals(TypologicalClassification.isolatingAnalytic));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.sov));
      expect(profile.hasTones, isTrue);
      expect(profile.hasGrammaticalGender, isFalse);
      expect(profile.specialCharacters, contains('ɛ'));
      expect(profile.specialCharacters, contains('ɔ'));
    });

    test('Predicate marker bridge and phonetic mappings are established', () {
      expect(profile.predicateMarkerBridge, containsKey(contains('S-Aux-O-V-X')));
      expect(profile.predicateMarkerBridge, containsKey(contains('Abstract Derivation')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('C / c')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('i ni ce / salaam alaykum'));
      expect(profile.culturalIslamicLexicon, containsKey('halali'));
      expect(profile.culturalIslamicLexicon, containsKey('misiri'));
      expect(profile.coreA1Vocabulary['I ni ce kosɛbɛ'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
