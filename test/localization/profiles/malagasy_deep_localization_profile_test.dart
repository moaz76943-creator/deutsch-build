import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/malagasy_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('MalagasyDeepLocalizationProfile Tests', () {
    const profile = MalagasyDeepLocalizationProfile();

    test('Linguistic properties correctly model Austronesian Malagasy standard', () {
      expect(profile.languageName, equals('Malagasy'));
      expect(profile.iso6391, equals('mg'));
      expect(profile.iso6392or3, equals('mlg'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.hasTones, isFalse);
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Rare VOS word order bridge is established', () {
      expect(profile.vosWordOrderBridge, containsKey(contains('Default VOS')));
      expect(profile.vosWordOrderBridge, containsKey(contains('Symmetric Voice')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Tr / tr')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('manao ahoana / salama'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('mousqué / masjid'));
      expect(profile.coreA1Vocabulary['Misaotra betsaka'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
