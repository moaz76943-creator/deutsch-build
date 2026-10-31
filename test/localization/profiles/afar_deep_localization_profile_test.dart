import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/afar_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('AfarDeepLocalizationProfile Tests', () {
    const profile = AfarDeepLocalizationProfile();

    test('Linguistic properties correctly model Cushitic Afar standard', () {
      expect(profile.languageName, equals('Afar'));
      expect(profile.iso6391, equals('aa'));
      expect(profile.iso6392or3, equals('aar'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.sov));
      expect(profile.hasTones, isTrue);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.pharyngealSpecialGraphemes.length, equals(3));
    });

    test('Case system alignment maps 5 Afar cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(5));
      expect(profile.getGermanCaseBridge('Absolutiv'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Nominativ'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Lokativ'), contains('in'));
    });

    test('Phonetic bridge identifies native pharyngeals and SOV mirror', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Sh')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Pharyngeal Advantage'), isNotEmpty));
      expect(profile.germanPhoneticBridges, containsPair(contains('SOV Subordinate'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('mahaba / salaam alaykum'));
      expect(profile.culturalIslamicLexicon, containsKey('xalaal'));
      expect(profile.culturalIslamicLexicon, containsKey('masiigida'));
      expect(profile.coreA1Vocabulary['Gaddali'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
