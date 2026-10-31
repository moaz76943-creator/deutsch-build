import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/albanian_deep_localization_profile.dart';

void main() {
  group('AlbanianDeepLocalizationProfile Tests', () {
    const profile = AlbanianDeepLocalizationProfile();

    test('Linguistic properties correctly model independent Albanian branch', () {
      expect(profile.languageName, equals('Albanian'));
      expect(profile.iso6391, equals('sq'));
      expect(profile.iso6392, equals('sqi'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Albanian'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasPostposedDefiniteArticles, isTrue);
      expect(profile.hasNativeGermanUSound, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.specialCharacters, contains('ç'));
      expect(profile.specialCharacters, contains('ë'));
      expect(profile.specialCharacters, contains('sh'));
    });

    test('Case system alignment maps 5 Albanian cases to German equivalents', () {
      expect(profile.caseSystemAlignment.length, equals(5));
      expect(profile.getGermanCaseBridge('Emërore'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Gjinore'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Dhanore'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Kallëzore'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Rrjedhore'), contains('aus'));
    });

    test('Phonetic bridge identifies native /y/ for German ü and /ts/ for German z', () {
      expect(profile.germanPhoneticBridges, containsPair('ü /y/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Sh')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Ç')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('selam / përshëndetje'));
      expect(profile.culturalIslamicLexicon, containsKey('hallall'));
      expect(profile.culturalIslamicLexicon, containsKey('namaz / falje'));
      expect(profile.culturalIslamicLexicon, containsKey('xhami'));
      expect(profile.coreA1Vocabulary['Shumë faleminderit'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
