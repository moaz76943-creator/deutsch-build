import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/kurdish_kurmanji_deep_localization_profile.dart';

void main() {
  group('KurdishKurmanjiDeepLocalizationProfile Tests', () {
    const profile = KurdishKurmanjiDeepLocalizationProfile();

    test('Linguistic and typological metadata conform to Hawar Kurmanji standard', () {
      expect(profile.languageName, equals('Kurdish Kurmanji'));
      expect(profile.iso6391, equals('ku'));
      expect(profile.iso6392, equals('kmr'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, equals('Northwestern Iranian'));
      expect(profile.writingDirection, equals('ltr'));
      expect(profile.hasSplitErgativity, isTrue);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.hasHawarLetter('Ş'), isTrue);
      expect(profile.hasHawarLetter('Ç'), isTrue);
      expect(profile.hasHawarLetter('Û'), isTrue);
    });

    test('Phonetic bridge establishes 1:1 acoustic mappings', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Ş / ş')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Ç / ç')));
      expect(profile.germanPhoneticBridges, containsPair(contains('ach-Laut'), contains('X / x')));
    });

    test('Gender and case alignment ease German article learning', () {
      expect(profile.getCaseBridge('xwerû'), contains('Nominativ'));
      expect(profile.getCaseBridge('tewandî'), contains('Akkusativ'));
      expect(profile.caseSystemAlignment, containsPair(contains('Izafe'), contains('Genitiv')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('silav'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('nimêj'));
      expect(profile.coreA1Vocabulary['Gelek spas'], equals('Vielen Dank'));
      expect(profile.coreA1Vocabulary['Erê'], equals('Ja'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
