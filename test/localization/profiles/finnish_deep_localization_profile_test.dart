import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/finnish_deep_localization_profile.dart';

void main() {
  group('FinnishDeepLocalizationProfile Tests', () {
    const profile = FinnishDeepLocalizationProfile();

    test('Linguistic properties correctly model Finnic Finnish standard', () {
      expect(profile.languageName, equals('Finnish'));
      expect(profile.iso6391, equals('fi'));
      expect(profile.iso6392, equals('fin'));
      expect(profile.languageFamily, equals('Uralic'));
      expect(profile.branch, equals('Finnic'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasVowelHarmony, isTrue);
      expect(profile.hasConsonantGradation, isTrue);
      expect(profile.hasNativeGermanUmlauts, isTrue);
      expect(profile.specialCharacters, contains('ä'));
      expect(profile.specialCharacters, contains('ö'));
      expect(profile.specialCharacters, contains('y'));
    });

    test('Case system alignment maps 13 cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, greaterThanOrEqualTo(13));
      expect(profile.getGermanCaseBridge('Nominatiivi'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Genetiivi'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Inessiivi'), contains('in'));
      expect(profile.getGermanCaseBridge('Elatiivi'), contains('aus'));
      expect(profile.getGermanCaseBridge('Adessiivi'), contains('auf'));
      expect(profile.getGermanCaseBridge('Abessiivi'), contains('ohne'));
    });

    test('Phonetic bridge identifies native match for Ä, Ö, and Y to German Ü', () {
      expect(profile.germanPhoneticBridges, containsPair('ä /ɛ/ & ö /ø/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ü /y/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Phonemic Quantity')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('hei / päivää / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('rukous / namaz'));
      expect(profile.coreA1Vocabulary['Paljon kiitoksia'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
