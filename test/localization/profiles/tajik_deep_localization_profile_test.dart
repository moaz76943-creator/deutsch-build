import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/tajik_deep_localization_profile.dart';

void main() {
  group('TajikDeepLocalizationProfile Tests', () {
    const profile = TajikDeepLocalizationProfile();

    test('Linguistic properties correctly model Cyrillic Tajik standard', () {
      expect(profile.languageName, equals('Tajik'));
      expect(profile.iso6391, equals('tg'));
      expect(profile.iso6392, equals('tgk'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Southwestern Iranian'));
      expect(profile.hasIzafeConstruct, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('Ғ'));
      expect(profile.specialCharacters, contains('Ӣ'));
      expect(profile.specialCharacters, contains('Ӯ'));
      expect(profile.specialCharacters, contains('Ҳ'));
    });

    test('Case and preposition alignment maps to German declension network', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Subject'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Definite Direct Object'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('бо'), contains('mit'));
      expect(profile.getGermanCaseBridge('аз'), contains('aus'));
      expect(profile.getGermanCaseBridge('Izafe'), contains('Genitiv'));
    });

    test('Phonetic bridge accurately assists German sound acquisition', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Ш')));
      expect(profile.germanPhoneticBridges, containsPair(contains('ach-Laut'), contains('Х')));
      expect(profile.germanPhoneticBridges, containsPair('h /h/', contains('Ҳ')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('салом / ассалому алайкум'));
      expect(profile.culturalIslamicLexicon, containsKey('ҳалол'));
      expect(profile.culturalIslamicLexicon, containsKey('намоз'));
      expect(profile.coreA1Vocabulary['Ташаккури зиёд'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
