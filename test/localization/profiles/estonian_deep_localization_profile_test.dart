import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/estonian_deep_localization_profile.dart';

void main() {
  group('EstonianDeepLocalizationProfile Tests', () {
    const profile = EstonianDeepLocalizationProfile();

    test('Linguistic properties correctly model Finnic Estonian standard', () {
      expect(profile.languageName, equals('Estonian'));
      expect(profile.iso6391, equals('et'));
      expect(profile.iso6392, equals('est'));
      expect(profile.languageFamily, equals('Uralic'));
      expect(profile.branch, equals('Finnic'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasHanseaticGermanSubstrate, isTrue);
      expect(profile.hasNativeGermanUmlauts, isTrue);
      expect(profile.specialCharacters, contains('ä'));
      expect(profile.specialCharacters, contains('ö'));
      expect(profile.specialCharacters, contains('ü'));
      expect(profile.specialCharacters, contains('õ'));
    });

    test('Case system alignment maps 14 cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(14));
      expect(profile.getGermanCaseBridge('Nimetav'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Omastav'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Seesütlev'), contains('in'));
      expect(profile.getGermanCaseBridge('Seestütlev'), contains('aus'));
      expect(profile.getGermanCaseBridge('Ilmaütlev'), contains('ohne'));
      expect(profile.getGermanCaseBridge('Kaasaütlev'), contains('mit'));
    });

    test('Hanseatic cognates and phonetic bridges establish massive German overlap', () {
      expect(profile.hanseaticCognateBridges, containsPair('arst', contains('Arzt')));
      expect(profile.hanseaticCognateBridges, containsPair('kool', contains('Schule')));
      expect(profile.hanseaticCognateBridges, containsPair('loss', contains('Schloss')));
      expect(profile.germanPhoneticBridges, containsPair('ä, ö, ü', contains('100% Native Triad')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('tere / päevast / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('palvus / namaz'));
      expect(profile.coreA1Vocabulary['Suur aitäh'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
