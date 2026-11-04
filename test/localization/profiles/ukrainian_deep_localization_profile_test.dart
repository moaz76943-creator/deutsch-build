import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/ukrainian_deep_localization_profile.dart';

void main() {
  group('UkrainianDeepLocalizationProfile Tests', () {
    const profile = UkrainianDeepLocalizationProfile();

    test('Linguistic properties correctly model East Slavic Ukrainian standard', () {
      expect(profile.languageName, equals('Ukrainian'));
      expect(profile.iso6391, equals('uk'));
      expect(profile.iso6392, equals('ukr'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('East Slavic'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasNativeGermanZSound, isTrue);
      expect(profile.hasGlottalHSound, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.specialCharacters, contains('Ґ'));
      expect(profile.specialCharacters, contains('Є'));
      expect(profile.specialCharacters, contains('І'));
      expect(profile.specialCharacters, contains('Ї'));
    });

    test('Case system alignment maps 7 cases to German declension structure', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Називний'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Родовий'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Давальний'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Знахідний'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Орудний'), contains('mit'));
    });

    test('Phonetic bridge identifies native matches for Г to H and Ц to Z', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('h /h/ & /ɦ/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('g /ɡ/', contains('Ґ / ґ')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Ш')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('добрий день / салам'));
      expect(profile.culturalIslamicLexicon.keys, contains('халяль / дозволене'));
      expect(profile.culturalIslamicLexicon.keys, contains('молитва / намаз'));
      expect(profile.coreA1Vocabulary['Щиро дякую'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
