import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/thai_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('ThaiDeepLocalizationProfile Tests', () {
    const profile = ThaiDeepLocalizationProfile();

    test('Linguistic properties correctly model Kra-Dai Thai standard', () {
      expect(profile.languageName, equals('Thai'));
      expect(profile.iso6391, equals('th'));
      expect(profile.iso6392or3, equals('tha'));
      expect(profile.typology, equals(TypologicalClassification.isolatingAnalytic));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isTrue);
      expect(profile.toneRegisters.length, equals(5));
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Omnidirectional cross-lingual transfer matrix is established', () {
      expect(profile.omnidirectionalBridges.keys, contains(contains('Austronesian/Malay')));
      expect(profile.omnidirectionalBridges.keys, contains(contains('Indic Sanskrit/Pali')));
      expect(profile.omnidirectionalBridges.keys, contains(contains('European Fusional')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('สวัสดี / ซะลาม'));
      expect(profile.culturalIslamicLexicon.keys, contains('ฮาลาล'));
      expect(profile.culturalIslamicLexicon.keys, contains('ละหมาด / นมาซ'));
      expect(profile.culturalIslamicLexicon.keys, contains('มัสยิด / สุเหร่า'));
      expect(profile.coreA1Vocabulary['ขอบคุณมาก'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
