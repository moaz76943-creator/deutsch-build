import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/icelandic_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('IcelandicDeepLocalizationProfile Tests', () {
    const profile = IcelandicDeepLocalizationProfile();

    test('Linguistic properties correctly model North Germanic Icelandic standard', () {
      expect(profile.languageName, equals('Icelandic'));
      expect(profile.iso6391, equals('is'));
      expect(profile.iso6392or3, equals('isl'));
      expect(profile.typology, equals(TypologicalClassification.fusionalInflected));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.v2VerbSecond));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasFourCases, isTrue);
      expect(profile.specialCharacters, contains('þ'));
      expect(profile.specialCharacters, contains('ð'));
      expect(profile.specialCharacters, contains('æ'));
      expect(profile.specialCharacters, contains('ö'));
    });

    test('4-case system alignment perfectly mirrors German 4 cases', () {
      expect(profile.fourCaseSystemAlignment.length, equals(4));
      expect(profile.fourCaseSystemAlignment, containsPair(contains('Nefnifall'), contains('Nominativ')));
      expect(profile.fourCaseSystemAlignment, containsPair(contains('Þolfall'), contains('Akkusativ')));
      expect(profile.fourCaseSystemAlignment, containsPair(contains('Þágufall'), contains('Dativ')));
      expect(profile.fourCaseSystemAlignment, containsPair(contains('Eignarfall'), contains('Genitiv')));
    });

    test('Phonetic bridge identifies 100% native matches for Ö and Æ to German umlauts', () {
      expect(profile.germanPhoneticBridges, containsPair('ö /ø/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ä /ɛ/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Germanic Case Twin'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('halló / góðan daginn / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('moska'));
      expect(profile.coreA1Vocabulary['Kærar þakkir'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
