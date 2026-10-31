import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/cebuano_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('CebuanoDeepLocalizationProfile Tests', () {
    const profile = CebuanoDeepLocalizationProfile();

    test('Linguistic properties correctly model Austronesian Cebuano standard', () {
      expect(profile.languageName, equals('Cebuano'));
      expect(profile.iso6391, equals('ceb'));
      expect(profile.iso6392or3, equals('ceb'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.vso));
      expect(profile.alignment, equals(GrammaticalAlignment.austronesianSymmetricVoice));
      expect(profile.hasTones, isFalse);
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Voice trigger alignment and particle mapping are verified', () {
      expect(profile.voiceTriggerSystemAlignment.length, greaterThanOrEqualTo(5));
      expect(profile.voiceTriggerSystemAlignment, containsPair(contains('Actor Trigger'), contains('active voice')));
      expect(profile.voiceTriggerSystemAlignment, containsPair(contains('Particle "ang"'), contains('Nominativ')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Ts / ts')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('kumusta / maayong adlaw / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('salamat / daghang salamat'));
      expect(profile.coreA1Vocabulary['Daghang salamat'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
