import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/lithuanian_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('LithuanianDeepLocalizationProfile Tests', () {
    const profile = LithuanianDeepLocalizationProfile();

    test('Linguistic properties correctly model Baltic Lithuanian standard', () {
      expect(profile.languageName, equals('Lithuanian'));
      expect(profile.iso6391, equals('lt'));
      expect(profile.iso6392or3, equals('lit'));
      expect(profile.typology, equals(TypologicalClassification.fusionalInflected));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isTrue);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.specialCharacters, contains('ą'));
      expect(profile.specialCharacters, contains('č'));
      expect(profile.specialCharacters, contains('š'));
      expect(profile.specialCharacters, contains('ž'));
    });

    test('7-case system alignment maps directly to German declensions', () {
      expect(profile.sevenCaseSystemAlignment.length, equals(7));
      expect(profile.sevenCaseSystemAlignment, containsPair(contains('Vardininkas'), contains('Nominativ')));
      expect(profile.sevenCaseSystemAlignment, containsPair(contains('Kilmininkas'), contains('Genitiv')));
      expect(profile.sevenCaseSystemAlignment, containsPair(contains('Naudininkas'), contains('Dativ')));
      expect(profile.sevenCaseSystemAlignment, containsPair(contains('Galininkas'), contains('Akkusativ')));
      expect(profile.sevenCaseSystemAlignment, containsPair(contains('Įnagininkas'), contains('mit')));
      expect(profile.sevenCaseSystemAlignment, containsPair(contains('Vietininkas'), contains('in')));
    });

    test('Phonetic bridge identifies 100% native matches for C, Š, and Č', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('100% Native Identity')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('labas / laba diena / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('mečetė'));
      expect(profile.coreA1Vocabulary['Labai ačiū'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
