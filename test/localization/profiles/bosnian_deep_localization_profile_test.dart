import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/bosnian_deep_localization_profile.dart';

void main() {
  group('BosnianDeepLocalizationProfile Tests', () {
    const profile = BosnianDeepLocalizationProfile();

    test('Linguistic properties correctly model South Slavic Bosnian standard', () {
      expect(profile.languageName, equals('Bosnian'));
      expect(profile.iso6391, equals('bs'));
      expect(profile.iso6392, equals('bos'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('South Slavic'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasNativeGermanZSound, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.specialCharacters, contains('č'));
      expect(profile.specialCharacters, contains('š'));
      expect(profile.specialCharacters, contains('ž'));
      expect(profile.genderEquivalenceMap.length, equals(3));
    });

    test('Case system alignment maps 7 cases to German declension structure', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Nominativ'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Akkusativ'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Instrumental'), contains('mit'));
    });

    test('Phonetic bridge identifies 100% native match for letter C to German Z', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Š')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Č')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('selam / dobar dan'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('namaz / salavat'));
      expect(profile.culturalIslamicLexicon.keys, contains('džamija'));
      expect(profile.coreA1Vocabulary['Hvala lijepa'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
