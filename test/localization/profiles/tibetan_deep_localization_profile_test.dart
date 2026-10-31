import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/tibetan_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('TibetanDeepLocalizationProfile Tests', () {
    const profile = TibetanDeepLocalizationProfile();

    test('Linguistic properties correctly model Bodish Tibetan standard', () {
      expect(profile.languageName, equals('Tibetan'));
      expect(profile.iso6391, equals('bo'));
      expect(profile.iso6392or3, equals('bod'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.sov));
      expect(profile.alignment, equals(GrammaticalAlignment.ergativeAbsolutive));
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Zhe-sa honorific registers and postpositional cases are established', () {
      expect(profile.zhesaHonorificBridge, containsKey(contains('Zhe-sa')));
      expect(profile.postpositionalCaseAlignment.length, equals(5));
      expect(profile.getGermanCaseBridge('Genitive'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Dative'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Ablative'), contains('aus'));
    });

    test('Phonetic bridge identifies 100% native matches for affricates and SOV mirror', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ཤ')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('ཅ')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('བཀྲ་ཤིས་བདེ་ལེགས / སަލཱམ'));
      expect(profile.culturalIslamicLexicon, containsKey('ཧ་ལཱལ'));
      expect(profile.culturalIslamicLexicon, containsKey('ཁ་ཆེའི་ལྷ་ཁང / མསྗིད'));
      expect(profile.coreA1Vocabulary['ཐུགས་རྗེ་ཆེ་ཞུ'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
