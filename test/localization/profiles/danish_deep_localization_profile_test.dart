import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/danish_deep_localization_profile.dart';

void main() {
  group('DanishDeepLocalizationProfile Tests', () {
    const profile = DanishDeepLocalizationProfile();

    test('Linguistic properties correctly model North Germanic Danish standard', () {
      expect(profile.languageName, equals('Danish'));
      expect(profile.iso6391, equals('da'));
      expect(profile.iso6392, equals('dan'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Germanic'));
      expect(profile.hasV2WordOrder, isTrue);
      expect(profile.hasStoedPhenomenon, isTrue);
      expect(profile.hasNativeGermanUmlauts, isTrue);
      expect(profile.specialCharacters, contains('æ'));
      expect(profile.specialCharacters, contains('ø'));
      expect(profile.specialCharacters, contains('å'));
    });

    test('Gender equivalence maps correctly to German articles', () {
      expect(profile.genderEquivalenceMap.length, equals(2));
      expect(profile.getGermanGenderBridge('Fælleskøn'), contains('Maskulinum'));
      expect(profile.getGermanGenderBridge('Intetkøn'), contains('Neutrum'));
      expect(profile.borderMinorityBridge.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Slesvig')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Phonetic bridge identifies 100% native matches for Æ, Ø, Y, and Stød', () {
      expect(profile.germanPhoneticBridges, containsPair('ö /ø/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ä /ɛ/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ü /y/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Stød & Knacklaut')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('hej / goddag / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('moské'));
      expect(profile.coreA1Vocabulary['Mange tak'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
