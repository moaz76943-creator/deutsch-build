import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/hungarian_deep_localization_profile.dart';

void main() {
  group('HungarianDeepLocalizationProfile Tests', () {
    const profile = HungarianDeepLocalizationProfile();

    test('Linguistic properties correctly model Ugric Hungarian standard', () {
      expect(profile.languageName, equals('Hungarian'));
      expect(profile.iso6391, equals('hu'));
      expect(profile.iso6392, equals('hun'));
      expect(profile.languageFamily, equals('Uralic'));
      expect(profile.branch, equals('Ugric'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasVowelHarmony, isTrue);
      expect(profile.hasNativeGermanUmlauts, isTrue);
      expect(profile.hasNativeGermanZSound, isTrue);
      expect(profile.specialCharacters, contains('ö'));
      expect(profile.specialCharacters, contains('ő'));
      expect(profile.specialCharacters, contains('ü'));
      expect(profile.specialCharacters, contains('ű'));
    });

    test('Case system alignment maps agglutinative cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, greaterThanOrEqualTo(10));
      expect(profile.getGermanCaseBridge('Nominatívus'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Akkuzatívus'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Dativus'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Inessivus'), contains('in'));
      expect(profile.getGermanCaseBridge('Elativus'), contains('aus'));
      expect(profile.getGermanCaseBridge('Instrumentalis'), contains('mit'));
    });

    test('Phonetic bridge identifies native match for letter C to Z and S to SCH', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair(contains('ö /ø/'), contains('100% Native Identity')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('jó napot / szalam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('ima / namaz'));
      expect(profile.coreA1Vocabulary['Köszönöm szépen'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
