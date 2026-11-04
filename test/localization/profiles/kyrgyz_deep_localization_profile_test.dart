import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/kyrgyz_deep_localization_profile.dart';

void main() {
  group('KyrgyzDeepLocalizationProfile Tests', () {
    const profile = KyrgyzDeepLocalizationProfile();

    test('Linguistic properties correctly model Kipchak Kyrgyz standard', () {
      expect(profile.languageName, equals('Kyrgyz'));
      expect(profile.iso6391, equals('ky'));
      expect(profile.iso6392, equals('kir'));
      expect(profile.languageFamily, equals('Turkic'));
      expect(profile.branch, contains('Kipchak'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasEightWayVowelHarmony, isTrue);
      expect(profile.hasNativeGermanUmlauts(), isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('Ө'));
      expect(profile.specialCharacters, contains('Ү'));
      expect(profile.specialCharacters, contains('Ң'));
    });

    test('Case system alignment maps 6 cases to German prepositions & declensions', () {
      expect(profile.caseSystemAlignment.length, equals(6));
      expect(profile.getGermanCaseBridge('Атооч'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Табыш'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Илик'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Барыш'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Чыгыш'), contains('aus'));
    });

    test('Phonetic bridge identifies native umlaut and labial harmony alignment', () {
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Ө /ө/')).having((entry) => entry.value, 'value', contains('100% Native'))));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ш')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Labial Harmony')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('салам / ассалому алейкум'));
      expect(profile.culturalIslamicLexicon.keys, contains('адал / халал'));
      expect(profile.culturalIslamicLexicon.keys, contains('намаз'));
      expect(profile.coreA1Vocabulary['Чоң рахмат'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
