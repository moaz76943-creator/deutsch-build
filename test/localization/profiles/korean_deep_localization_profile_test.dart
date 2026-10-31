import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/korean_deep_localization_profile.dart';

void main() {
  group('KoreanDeepLocalizationProfile Tests', () {
    const profile = KoreanDeepLocalizationProfile();

    test('Linguistic properties correctly model Koreanic Korean standard', () {
      expect(profile.languageName, equals('Korean'));
      expect(profile.iso6391, equals('ko'));
      expect(profile.iso6392, equals('kor'));
      expect(profile.languageFamily, equals('Koreanic'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasSOVVerbFinal, isTrue);
      expect(profile.wordOrder, contains('SOV'));
      expect(profile.primaryScript, contains('Hangul'));
    });

    test('Josa case particle alignment maps Korean markers to German cases', () {
      expect(profile.josaCaseParticleAlignment.length, greaterThanOrEqualTo(5));
      expect(profile.getGermanCaseBridge('이/가'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('을/를'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('에게'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('의'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('(으)로'), contains('mit'));
    });

    test('Phonetic bridge identifies matches and verb-final bridge', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('시/쉬')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('ㅊ')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Verb-Final'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('안녕하세요 / 살람'));
      expect(profile.culturalIslamicLexicon, containsKey('할랄'));
      expect(profile.culturalIslamicLexicon, containsKey('예배 / 살라트'));
      expect(profile.coreA1Vocabulary['대단히 감사합니다'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
