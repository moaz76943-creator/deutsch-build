import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/norwegian_deep_localization_profile.dart';

void main() {
  group('NorwegianDeepLocalizationProfile Tests', () {
    const profile = NorwegianDeepLocalizationProfile();

    test('Linguistic properties correctly model North Germanic Norwegian standard', () {
      expect(profile.languageName, equals('Norwegian'));
      expect(profile.iso6391, equals('no'));
      expect(profile.iso6392, equals('nor'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Germanic'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasV2WordOrder, isTrue);
      expect(profile.hasNativeGermanUmlauts, isTrue);
      expect(profile.supportedStandards.length, equals(2));
      expect(profile.specialCharacters, contains('æ'));
      expect(profile.specialCharacters, contains('ø'));
      expect(profile.specialCharacters, contains('å'));
    });

    test('3-gender equivalence directly mirrors German der, die, das', () {
      expect(profile.genderEquivalenceMap.length, equals(3));
      expect(profile.getGermanGenderBridge('Hankjønn'), contains('Maskulinum'));
      expect(profile.getGermanGenderBridge('Hunkjønn'), contains('Femininum'));
      expect(profile.getGermanGenderBridge('Intetkjønn'), contains('Neutrum'));
    });

    test('Phonetic bridge identifies 100% native matches for Æ, Ø, Y, and SKJ', () {
      expect(profile.germanPhoneticBridges, containsPair('ö /ø/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ä /ɛ/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ü /y/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('100% Native Identity')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('hei / god dag / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('moské'));
      expect(profile.coreA1Vocabulary['Tusen takk'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
