import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/punjabi_deep_localization_profile.dart';

void main() {
  group('PunjabiDeepLocalizationProfile Tests', () {
    const profile = PunjabiDeepLocalizationProfile();

    test('Linguistic properties correctly model Punjabi typological traits', () {
      expect(profile.languageName, equals('Punjabi'));
      expect(profile.iso6391, equals('pa'));
      expect(profile.iso6392, equals('pan'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Indo-Aryan'));
      expect(profile.hasTones, isTrue);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.supportedScripts.length, equals(2));
      expect(profile.supportedScripts.first, contains('Shahmukhi'));
      expect(profile.supportedScripts.last, contains('Gurmukhi'));
    });

    test('Phonetic bridge accurately assists German sound acquisition', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ਸ਼ / ش')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('ach-Laut')).having((entry) => entry.value, 'value', contains('ਖ਼ / خ'))));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('ਤ+ਸ')));
    });

    test('Case system alignment links postpositions to German cases', () {
      expect(profile.getGermanCaseBridge('Direct'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Genitive'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Locative'), contains('in'));
      expect(profile.getGermanCaseBridge('Ablative'), contains('aus'));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('ਸਲਾਮ / سلام'));
      expect(profile.culturalIslamicLexicon.keys, contains('ਹਲਾਲ / حلال'));
      expect(profile.culturalIslamicLexicon.keys, contains('ਨਮਾਜ਼ / نماز'));
      expect(profile.coreA1Vocabulary['ਬਹੁਤ ਸ਼ੁਕਰੀਆ / بہت شکریہ'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
