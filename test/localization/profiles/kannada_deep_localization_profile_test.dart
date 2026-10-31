import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/kannada_deep_localization_profile.dart';

void main() {
  group('KannadaDeepLocalizationProfile Tests', () {
    const profile = KannadaDeepLocalizationProfile();

    test('Linguistic properties correctly model Southern Dravidian Kannada', () {
      expect(profile.languageName, equals('Kannada'));
      expect(profile.iso6391, equals('kn'));
      expect(profile.iso6392, equals('kan'));
      expect(profile.languageFamily, equals('Dravidian'));
      expect(profile.branch, contains('Southern Dravidian'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasFormalPronounDistinction, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.pronominalGenderBridge.length, equals(5));
      expect(profile.pronominalGenderBridge, containsPair(contains('Avanu'), contains('er')));
      expect(profile.pronominalGenderBridge, containsPair(contains('Neevu'), contains('Sie')));
    });

    test('Vibhakti case system alignment maps to German case structure', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Prathama'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Dvitiya'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Chaturthi'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Saptami'), contains('in'));
    });

    test('Phonetic bridge accurately assists German sound acquisition', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ಶ')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('ತ್+ಸ್')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Honorific Register'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('ನಮಸ್ಕಾರ / ಸಲಾಂ'));
      expect(profile.culturalIslamicLexicon, containsKey('ಹಲಾಲ್'));
      expect(profile.culturalIslamicLexicon, containsKey('ನಮಾಜ್'));
      expect(profile.coreA1Vocabulary['ತುಂಬಾ ಧನ್ಯವಾದಗಳು'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
