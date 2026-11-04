import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/hindi_deep_localization_profile.dart';

void main() {
  group('HindiDeepLocalizationProfile Tests', () {
    const profile = HindiDeepLocalizationProfile();

    test('Linguistic properties correctly model Central Indo-Aryan Hindi', () {
      expect(profile.languageName, equals('Hindi'));
      expect(profile.iso6391, equals('hi'));
      expect(profile.iso6392, equals('hin'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Indo-Aryan'));
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.indoEuropeanCognateBridges.length, greaterThanOrEqualTo(6));
      expect(profile.indoEuropeanCognateBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Naam')).having((entry) => entry.value, 'value', contains('Name'))));
      expect(profile.indoEuropeanCognateBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Mata')).having((entry) => entry.value, 'value', contains('Mutter'))));
    });

    test('Case system alignment links postpositions to German cases', () {
      expect(profile.getGermanCaseBridge('Direct'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Ergative'), contains('past tense'));
      expect(profile.getGermanCaseBridge('Accusative'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Genitive'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Instrumental'), contains('mit'));
    });

    test('Phonetic bridge accurately assists German sound acquisition', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('श')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('त्+स')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Honorific Triad')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('नमस्ते / सलाम'));
      expect(profile.culturalIslamicLexicon.keys, contains('हलाल / शुद्ध'));
      expect(profile.culturalIslamicLexicon.keys, contains('नमाज़ / प्रार्थना'));
      expect(profile.coreA1Vocabulary['बहुत-बहुत धन्यवाद'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
