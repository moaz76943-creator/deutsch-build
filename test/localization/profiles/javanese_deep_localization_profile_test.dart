import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/javanese_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('JavaneseDeepLocalizationProfile Tests', () {
    const profile = JavaneseDeepLocalizationProfile();

    test('Linguistic properties correctly model Austronesian Javanese standard', () {
      expect(profile.languageName, equals('Javanese'));
      expect(profile.iso6391, equals('jv'));
      expect(profile.iso6392or3, equals('jav'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isFalse);
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Speech level honorific bridges (Ngoko/Krama) map to German address', () {
      expect(profile.speechLevelHonorificBridge.keys, contains(contains('Ngoko')));
      expect(profile.speechLevelHonorificBridge.keys, contains(contains('Krama')));
      expect(profile.speechLevelHonorificBridge.keys, contains(contains('Krama Inggil')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('C / c')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Sy / sy')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('sugeng / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('masjid'));
      expect(profile.coreA1Vocabulary['Matur nuwun sanget'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
