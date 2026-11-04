import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/kannada_deep_localization_profile.dart';

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
      expect(profile.pronominalGenderBridge.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Avanu')).having((entry) => entry.value, 'value', contains('er'))));
      expect(profile.pronominalGenderBridge.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Neevu')).having((entry) => entry.value, 'value', contains('Sie'))));
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
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Honorific Register')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('ನಮಸ್ಕಾರ / ಸಲಾಂ'));
      expect(profile.culturalIslamicLexicon.keys, contains('ಹಲಾಲ್'));
      expect(profile.culturalIslamicLexicon.keys, contains('ನಮಾಜ್'));
      expect(profile.coreA1Vocabulary['ತುಂಬಾ ಧನ್ಯವಾದಗಳು'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
