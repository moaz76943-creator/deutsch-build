import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/romanian_deep_localization_profile.dart';

void main() {
  group('RomanianDeepLocalizationProfile Tests', () {
    const profile = RomanianDeepLocalizationProfile();

    test('Linguistic properties correctly model Eastern Romance Romanian standard', () {
      expect(profile.languageName, equals('Romanian'));
      expect(profile.iso6391, equals('ro'));
      expect(profile.iso6392, equals('ron'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Romance'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasNativeGermanZSound, isTrue);
      expect(profile.hasNativeGermanSCHSound, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.specialCharacters, contains('ș'));
      expect(profile.specialCharacters, contains('ț'));
      expect(profile.genderEquivalenceMap.length, equals(3));
    });

    test('Case system alignment maps Romanian case pairs to German declensions', () {
      expect(profile.caseSystemAlignment.length, greaterThanOrEqualTo(5));
      expect(profile.getGermanCaseBridge('Nominativ'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Acuzativ'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Instrumentalis'), contains('mit'));
    });

    test('Phonetic bridge identifies 100% native matches for Ț to Z and Ș to SCH', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair(contains('3-Gender Advantage'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('bună ziua / salut / selam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('geamie / moschee'));
      expect(profile.coreA1Vocabulary['Vă mulțumesc foarte mult'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
