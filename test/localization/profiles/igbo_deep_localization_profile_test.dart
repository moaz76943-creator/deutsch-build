import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/igbo_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('IgboDeepLocalizationProfile Tests', () {
    const profile = IgboDeepLocalizationProfile();

    test('Linguistic properties correctly model Volta-Niger Igbo standard', () {
      expect(profile.languageName, equals('Igbo'));
      expect(profile.iso6391, equals('ig'));
      expect(profile.iso6392or3, equals('ibo'));
      expect(profile.typology, equals(TypologicalClassification.isolatingAnalytic));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isTrue);
      expect(profile.hasGrammaticalGender, isFalse);
      expect(profile.onwuSpecialGraphemes, contains('ị'));
      expect(profile.onwuSpecialGraphemes, contains('ọ'));
      expect(profile.onwuSpecialGraphemes, contains('ụ'));
    });

    test('Verbal compounding and phonetic bridges are established', () {
      expect(profile.verbalCompoundingBridge.keys, contains(contains('Verbal Extensional')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Sh')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Ch')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('ndewo / kedu / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('ụlọ alakụba'));
      expect(profile.coreA1Vocabulary['Daalụ nke ukwuu'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
