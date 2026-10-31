import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/odia_deep_localization_profile.dart';

void main() {
  group('OdiaDeepLocalizationProfile Tests', () {
    const profile = OdiaDeepLocalizationProfile();

    test('Linguistic properties correctly model Eastern Indo-Aryan Odia', () {
      expect(profile.languageName, equals('Odia'));
      expect(profile.iso6391, equals('or'));
      expect(profile.iso6392, equals('ori'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Eastern zone'));
      expect(profile.hasGrammaticalArticles, isFalse);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('ଳ'));
      expect(profile.specialCharacters, contains('ଡ଼'));
    });

    test('Case system alignment maps 7 cases to German prepositions & declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Prathama'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Dvitiya'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Tritiya'), contains('mit'));
      expect(profile.getGermanCaseBridge('Panchami'), contains('aus'));
    });

    test('Phonetic bridge accurately assists German sound acquisition', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ଶ')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('ତ୍+ସ')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Article System'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('ନମସ୍କାର / ସଲାମ'));
      expect(profile.culturalIslamicLexicon, containsKey('ହଲାଲ'));
      expect(profile.culturalIslamicLexicon, containsKey('ନମାଜ'));
      expect(profile.coreA1Vocabulary['ଅନେକ ଅନେକ ଧନ୍ୟବାଦ'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
