import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/spanish_deep_localization_profile.dart';

void main() {
  group('SpanishDeepLocalizationProfile Tests', () {
    const profile = SpanishDeepLocalizationProfile();

    test('Linguistic properties correctly model Ibero-Romance Spanish standard', () {
      expect(profile.languageName, equals('Spanish'));
      expect(profile.iso6391, equals('es'));
      expect(profile.iso6392, equals('spa'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Romance'));
      expect(profile.hasTwoGenders, isTrue);
      expect(profile.hasSubjunctiveMood, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.specialCharacters, contains('ñ'));
      expect(profile.specialCharacters, contains('¿'));
    });

    test('Case and preposition alignment maps to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(6));
      expect(profile.getGermanCaseBridge('Nominativ'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Akkusativ'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Instrumentalis'), contains('mit'));
    });

    test('Phonetic bridge identifies native match for letter J to German ach-Laut', () {
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('ach-Laut')).having((entry) => entry.value, 'value', contains('100% Native Identity'))));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('t+s')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Prothetic E')).having((entry) => entry.value, 'value', isNotEmpty)));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Subjunctive')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('hola / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('ojalá'));
      expect(profile.culturalIslamicLexicon.keys, contains('mezquita'));
      expect(profile.coreA1Vocabulary['Muchas gracias'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
