import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/latvian_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('LatvianDeepLocalizationProfile Tests', () {
    const profile = LatvianDeepLocalizationProfile();

    test('Linguistic properties correctly model Baltic Latvian standard', () {
      expect(profile.languageName, equals('Latvian'));
      expect(profile.iso6391, equals('lv'));
      expect(profile.iso6392or3, equals('lav'));
      expect(profile.typology, equals(TypologicalClassification.fusionalInflected));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isFalse);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.specialCharacters, contains('ā'));
      expect(profile.specialCharacters, contains('š'));
      expect(profile.specialCharacters, contains('č'));
    });

    test('6-case system alignment maps to German declensions', () {
      expect(profile.sixCaseSystemAlignment.length, equals(6));
      expect(profile.sixCaseSystemAlignment, containsPair(contains('Nominatīvs'), contains('Nominativ')));
      expect(profile.sixCaseSystemAlignment, containsPair(contains('Ģenitīvs'), contains('Genitiv')));
      expect(profile.sixCaseSystemAlignment, containsPair(contains('Datīvs'), contains('Dativ')));
      expect(profile.sixCaseSystemAlignment, containsPair(contains('Akuzatīvs'), contains('Akkusativ')));
    });

    test('Phonetic bridge identifies 100% native matches for C and Š', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Initial Stress'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('sveiki / labdien / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('mošeja'));
      expect(profile.coreA1Vocabulary['Liels paldies'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
