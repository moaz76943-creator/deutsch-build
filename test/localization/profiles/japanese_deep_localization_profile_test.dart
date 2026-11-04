import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/japanese_deep_localization_profile.dart';

void main() {
  group('JapaneseDeepLocalizationProfile Tests', () {
    const profile = JapaneseDeepLocalizationProfile();

    test('Linguistic properties correctly model Japonic Japanese standard', () {
      expect(profile.languageName, equals('Japanese'));
      expect(profile.iso6391, equals('ja'));
      expect(profile.iso6392, equals('jpn'));
      expect(profile.languageFamily, equals('Japonic'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasSOVVerbFinal, isTrue);
      expect(profile.wordOrder, contains('SOV'));
      expect(profile.scripts.length, equals(3));
    });

    test('Particle case alignment maps Japanese postpositions to German cases', () {
      expect(profile.particleCaseAlignment.length, greaterThanOrEqualTo(5));
      expect(profile.getGermanCaseBridge('が'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('を'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('に'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('の'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('で'), contains('mit'));
    });

    test('Phonetic bridge identifies native match for letter TSU to German Z and verb-final bridge', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Sh')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Ch')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Verb-Final')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('こんにちは / セラーム'));
      expect(profile.culturalIslamicLexicon.keys, contains('ハラール'));
      expect(profile.culturalIslamicLexicon.keys, contains('礼拝 / ナマズ'));
      expect(profile.coreA1Vocabulary['ありがとうございます'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
