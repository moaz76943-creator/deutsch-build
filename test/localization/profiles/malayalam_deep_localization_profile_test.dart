import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/malayalam_deep_localization_profile.dart';

void main() {
  group('MalayalamDeepLocalizationProfile Tests', () {
    const profile = MalayalamDeepLocalizationProfile();

    test('Linguistic properties correctly model Southern Dravidian Malayalam', () {
      expect(profile.languageName, equals('Malayalam'));
      expect(profile.iso6391, equals('ml'));
      expect(profile.iso6392, equals('mal'));
      expect(profile.languageFamily, equals('Dravidian'));
      expect(profile.branch, contains('Southern Dravidian'));
      expect(profile.hasPersonalVerbInflections, isFalse);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.chilluLetters.length, greaterThanOrEqualTo(5));
      expect(profile.chilluLetters, contains('ൺ'));
      expect(profile.chilluLetters, contains('ൻ'));
      expect(profile.chilluLetters, contains('ർ'));
    });

    test('Case system alignment maps 7 cases to German prepositions & declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Prathama'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Dvitiya'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Tritiya'), contains('mit'));
      expect(profile.getGermanCaseBridge('Panchami'), contains('aus'));
    });

    test('Phonetic bridge highlights Chillu codas and verb conjugation drills', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ശ')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('ത്+സ്')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Verb Conjugation'), isNotEmpty));
      expect(profile.germanPhoneticBridges, containsPair(contains('Chillu Coda'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('നമസ്കാരം / സലാം'));
      expect(profile.culturalIslamicLexicon, containsKey('ഹലാൽ'));
      expect(profile.culturalIslamicLexicon, containsKey('നിസ്കാരം / നമസ്കാരം'));
      expect(profile.coreA1Vocabulary['വളരെ നന്ദി'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
