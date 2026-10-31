import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/mongolian_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('MongolianDeepLocalizationProfile Tests', () {
    const profile = MongolianDeepLocalizationProfile();

    test('Linguistic properties correctly model Mongolic standard', () {
      expect(profile.languageName, equals('Mongolian'));
      expect(profile.iso6391, equals('mn'));
      expect(profile.iso6392or3, equals('mon'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.sov));
      expect(profile.hasNativeGermanUmlauts, isTrue);
      expect(profile.supportedScripts.length, equals(2));
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Case system alignment maps 8 Mongolian cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(8));
      expect(profile.getGermanCaseBridge('Нэрлэх'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Харьяалах'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Заах'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Гарах'), contains('aus'));
      expect(profile.getGermanCaseBridge('Үйлдэх'), contains('mit'));
    });

    test('Phonetic bridge identifies 100% native matches for umlauts and Ц to Z', () {
      expect(profile.germanPhoneticBridges, containsPair('ö /ø/ & ü /y/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ch /x/ (ach-Laut)', contains('100% Native Identity')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('сайн байна уу / салам'));
      expect(profile.culturalIslamicLexicon, containsKey('халал'));
      expect(profile.culturalIslamicLexicon, containsKey('лалын сүм / сүм'));
      expect(profile.coreA1Vocabulary['Маш их баярлалаа'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
