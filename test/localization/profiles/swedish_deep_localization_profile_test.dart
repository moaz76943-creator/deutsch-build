import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/swedish_deep_localization_profile.dart';

void main() {
  group('SwedishDeepLocalizationProfile Tests', () {
    const profile = SwedishDeepLocalizationProfile();

    test('Linguistic properties correctly model North Germanic Swedish standard', () {
      expect(profile.languageName, equals('Swedish'));
      expect(profile.iso6391, equals('sv'));
      expect(profile.iso6392, equals('swe'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Germanic'));
      expect(profile.hasV2WordOrder, isTrue);
      expect(profile.hasNativeGermanUmlauts, isTrue);
      expect(profile.wordOrder, contains('V2'));
      expect(profile.specialCharacters, contains('å'));
      expect(profile.specialCharacters, contains('ä'));
      expect(profile.specialCharacters, contains('ö'));
    });

    test('Gender and double definiteness maps correctly to German adjective declensions', () {
      expect(profile.genderEquivalenceMap.length, equals(2));
      expect(profile.getGermanGenderBridge('Utrum'), contains('Maskulinum'));
      expect(profile.getGermanGenderBridge('Neutrum'), contains('Neutrum'));
      expect(profile.doubleDefinitenessBridge, containsPair(contains('Dubbel'), contains('große')));
    });

    test('Phonetic bridge identifies 100% native matches for Ä, Ö, and Y to German Ü', () {
      expect(profile.germanPhoneticBridges, containsPair('ä /ɛ/ & ö /ø/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ü /y/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('t+s')));
      expect(profile.germanPhoneticBridges, containsPair(contains('V2 Acceleration'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('hej / hejsan / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('moské'));
      expect(profile.coreA1Vocabulary['Tack så mycket'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
