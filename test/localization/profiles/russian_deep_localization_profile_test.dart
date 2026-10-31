import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/russian_deep_localization_profile.dart';

void main() {
  group('RussianDeepLocalizationProfile Tests', () {
    const profile = RussianDeepLocalizationProfile();

    test('Linguistic properties correctly model East Slavic Russian standard', () {
      expect(profile.languageName, equals('Russian'));
      expect(profile.iso6391, equals('ru'));
      expect(profile.iso6392, equals('rus'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('East Slavic'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasNativeGermanZSound, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.genderEquivalenceMap.length, equals(3));
    });

    test('Case system alignment maps 6 cases to German declension structure', () {
      expect(profile.caseSystemAlignment.length, equals(6));
      expect(profile.getGermanCaseBridge('Именительный'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Родительный'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Дательный'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Винительный'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Творительный'), contains('mit'));
    });

    test('Phonetic bridge identifies native match for letter Ц to German Z', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Ш')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Ч')));
      expect(profile.germanPhoneticBridges, containsPair(contains('ach-Laut'), contains('Х')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('здравствуйте / салам'));
      expect(profile.culturalIslamicLexicon, containsKey('халяль / дозволенное'));
      expect(profile.culturalIslamicLexicon, containsKey('молитва / намаз'));
      expect(profile.coreA1Vocabulary['Большое спасибо'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
