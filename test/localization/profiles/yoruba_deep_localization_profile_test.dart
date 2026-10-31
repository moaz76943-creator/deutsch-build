import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/yoruba_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('YorubaDeepLocalizationProfile Tests', () {
    const profile = YorubaDeepLocalizationProfile();

    test('Linguistic properties correctly model Volta-Niger Yoruba standard', () {
      expect(profile.languageName, equals('Yoruba'));
      expect(profile.iso6391, equals('yo'));
      expect(profile.iso6392or3, equals('yor'));
      expect(profile.typology, equals(TypologicalClassification.isolatingAnalytic));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isTrue);
      expect(profile.toneRegisters.length, equals(3));
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Serial verb bridges and phonetic mapping are established', () {
      expect(profile.serialVerbBridge, containsKey(contains('Serial Verb')));
      expect(profile.serialVerbBridge, containsKey(contains('Prepositional Case')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Ṣ / ṣ')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('báwo / àlàáfíà / salama'));
      expect(profile.culturalIslamicLexicon, containsKey('hàláàlì'));
      expect(profile.culturalIslamicLexicon, containsKey('mọ́ṣálásí'));
      expect(profile.coreA1Vocabulary['Ẹ ṣe púpọ̀'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
