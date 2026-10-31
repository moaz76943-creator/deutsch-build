import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/vietnamese_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('VietnameseDeepLocalizationProfile Tests', () {
    const profile = VietnameseDeepLocalizationProfile();

    test('Linguistic properties correctly model Austroasiatic Vietnamese standard', () {
      expect(profile.languageName, equals('Vietnamese'));
      expect(profile.iso6391, equals('vi'));
      expect(profile.iso6392or3, equals('vie'));
      expect(profile.typology, equals(TypologicalClassification.isolatingAnalytic));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isTrue);
      expect(profile.hasGrammaticalGender, isFalse);
      expect(profile.toneRegisters.length, equals(6));
    });

    test('Omnidirectional cross-lingual transfer matrix is established', () {
      expect(profile.omnidirectionalBridges, containsKey(contains('Sino-Vietnamese')));
      expect(profile.omnidirectionalBridges, containsKey(contains('Southeast Asian')));
      expect(profile.omnidirectionalBridges, containsKey(contains('Western Fusional')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('xin chào / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal / hợp giáo quy'));
      expect(profile.culturalIslamicLexicon, containsKey('cầu nguyện / salat'));
      expect(profile.coreA1Vocabulary['Cảm ơn rất nhiều'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
