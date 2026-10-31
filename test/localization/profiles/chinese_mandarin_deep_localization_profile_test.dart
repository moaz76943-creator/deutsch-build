import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/chinese_mandarin_deep_localization_profile.dart';

void main() {
  group('ChineseMandarinDeepLocalizationProfile Tests', () {
    const profile = ChineseMandarinDeepLocalizationProfile();

    test('Linguistic properties correctly model Sinitic Mandarin standard', () {
      expect(profile.languageName, equals('Chinese Mandarin'));
      expect(profile.iso6391, equals('zh'));
      expect(profile.iso6392, equals('zho'));
      expect(profile.languageFamily, equals('Sino-Tibetan'));
      expect(profile.branch, equals('Sinitic'));
      expect(profile.isIsolating, isTrue);
      expect(profile.hasTones, isTrue);
      expect(profile.hasNativeGermanUSound, isTrue);
      expect(profile.hasNativeGermanZSound, isTrue);
      expect(profile.wordOrder, contains('SVO'));
    });

    test('TeKaMoLo and case alignment map Chinese structures to German syntax', () {
      expect(profile.tekamoloSyntacticBridge, containsPair(contains('Temporal-Locative'), contains('TeKaMoLo')));
      expect(profile.getGermanCaseBridge('主格'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('与格'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('属格'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('用'), contains('mit'));
    });

    test('Phonetic bridge identifies 100% native matches for Pinyin C to Z and Ü to Ü', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ü /y/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Sh')));
      expect(profile.germanPhoneticBridges, containsPair(contains('ich-Laut'), contains('X / x')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('你好 / 色兰'));
      expect(profile.culturalIslamicLexicon, containsKey('清真 / 哈俩里'));
      expect(profile.culturalIslamicLexicon, containsKey('礼拜 / 乃玛孜'));
      expect(profile.culturalIslamicLexicon, containsKey('清真寺'));
      expect(profile.coreA1Vocabulary['非常感谢'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
