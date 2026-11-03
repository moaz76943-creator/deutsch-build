import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/sundanese_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('SundaneseDeepLocalizationProfile Tests', () {
    const profile = SundaneseDeepLocalizationProfile();

    test('Linguistic properties correctly model Austronesian Sundanese standard', () {
      expect(profile.languageName, equals('Sundanese'));
      expect(profile.iso6391, equals('su'));
      expect(profile.iso6392or3, equals('sun'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isFalse);
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Speech level honorific bridges (Loma/Lemes) map to German address', () {
      expect(profile.speechLevelHonorificBridge.keys, contains(contains('Loma')));
      expect(profile.speechLevelHonorificBridge.keys, contains(contains('Lemes')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('C / c')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Sy / sy')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('wilujeng / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('masjid'));
      expect(profile.coreA1Vocabulary['Hatur nuhun pisan'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
