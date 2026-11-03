import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/armenian_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('ArmenianDeepLocalizationProfile Tests', () {
    const profile = ArmenianDeepLocalizationProfile();

    test('Linguistic properties correctly model independent Armenian branch', () {
      expect(profile.languageName, equals('Armenian'));
      expect(profile.iso6391, equals('hy'));
      expect(profile.iso6392or3, equals('hye'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.sov));
      expect(profile.alphabetLetterCount, equals(39));
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Case system alignment maps 7 Armenian cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Ուղղական'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Սեռական'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Տրական'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Բացառական'), contains('aus'));
      expect(profile.getGermanCaseBridge('Գործիական'), contains('mit'));
      expect(profile.getGermanCaseBridge('Ներգոյական'), contains('in'));
    });

    test('Phonetic bridge identifies 100% native matches for affricates and fricatives', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Շ')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('ach-Laut')).having((entry) => entry.value, 'value', contains('Խ'))));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('բարև / բարև ձեզ / սալամ'));
      expect(profile.culturalIslamicLexicon.keys, contains('հալալ'));
      expect(profile.culturalIslamicLexicon.keys, contains('մզկիթ'));
      expect(profile.coreA1Vocabulary['Շատ շնորհակալություն'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
