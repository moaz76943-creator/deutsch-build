import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/afar_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

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
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Pharyngeal Advantage')).having((entry) => entry.value, 'value', isNotEmpty)));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('SOV Subordinate')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('mahaba / salaam alaykum'));
      expect(profile.culturalIslamicLexicon.keys, contains('xalaal'));
      expect(profile.culturalIslamicLexicon.keys, contains('masiigida'));
      expect(profile.coreA1Vocabulary['Gaddali'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
