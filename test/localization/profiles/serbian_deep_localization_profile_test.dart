import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/serbian_deep_localization_profile.dart';

void main() {
  group('SerbianDeepLocalizationProfile Tests', () {
    const profile = SerbianDeepLocalizationProfile();

    test('Linguistic properties correctly model South Slavic Serbian standard', () {
      expect(profile.languageName, equals('Serbian'));
      expect(profile.iso6391, equals('sr'));
      expect(profile.iso6392, equals('srp'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('South Slavic'));
      expect(profile.supportedScripts.length, equals(2));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasNativeGermanZSound, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.genderEquivalenceMap.length, equals(3));
    });

    test('Case system alignment maps 7 Serbian cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Номинатив'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Генитив'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Датив'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Акузатив'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Инструментал'), contains('mit'));
    });

    test('Phonetic bridge identifies native match for letter Ц/C to German Z', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Ш')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Ч')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('добар дан / селам'));
      expect(profile.culturalIslamicLexicon, containsKey('халал'));
      expect(profile.culturalIslamicLexicon, containsKey('молитва / намаз'));
      expect(profile.coreA1Vocabulary['Хвала лепо'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
