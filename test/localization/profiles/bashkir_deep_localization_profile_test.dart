import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/bashkir_deep_localization_profile.dart';

void main() {
  group('BashkirDeepLocalizationProfile Tests', () {
    const profile = BashkirDeepLocalizationProfile();

    test('Linguistic properties correctly model Kipchak Bashkir standard', () {
      expect(profile.languageName, equals('Bashkir'));
      expect(profile.iso6391, equals('ba'));
      expect(profile.iso6392, equals('bak'));
      expect(profile.languageFamily, equals('Turkic'));
      expect(profile.branch, contains('Kipchak'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasInterdentalFricatives, isTrue);
      expect(profile.hasAllThreeGermanUmlauts, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('Ә'));
      expect(profile.specialCharacters, contains('Ө'));
      expect(profile.specialCharacters, contains('Ү'));
      expect(profile.specialCharacters, contains('Ҫ'));
      expect(profile.specialCharacters, contains('Ҙ'));
      expect(profile.specialCharacters, contains('Һ'));
    });

    test('Case system alignment maps 6 cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(6));
      expect(profile.getGermanCaseBridge('Төп'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Төшөм'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Эйәлек'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Төбәү'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Сығыш'), contains('aus'));
    });

    test('Phonetic bridge identifies native triple umlaut alignment', () {
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Triple Umlaut')).having((entry) => entry.value, 'value', contains('100% Native Triad'))));
      expect(profile.germanPhoneticBridges, containsPair('h /h/', contains('Һ')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Ш')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('һаумыһығыҙ / сәләм'));
      expect(profile.culturalIslamicLexicon.keys, contains('хәләл'));
      expect(profile.culturalIslamicLexicon.keys, contains('намаҙ'));
      expect(profile.culturalIslamicLexicon.keys, contains('мәсет'));
      expect(profile.coreA1Vocabulary['Оло рәхмәт'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
