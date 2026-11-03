import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/dutch_deep_localization_profile.dart';

void main() {
  group('DutchDeepLocalizationProfile Tests', () {
    const profile = DutchDeepLocalizationProfile();

    test('Linguistic properties correctly model West Germanic Dutch standard', () {
      expect(profile.languageName, equals('Dutch'));
      expect(profile.iso6391, equals('nl'));
      expect(profile.iso6392, equals('nld'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Germanic'));
      expect(profile.hasV2WordOrder, isTrue);
      expect(profile.hasSeparableVerbs, isTrue);
      expect(profile.hasSatzklammer, isTrue);
      expect(profile.wordOrder, contains('V2'));
    });

    test('Syntactic twin bridges mirror German syntax architecture exactly', () {
      expect(profile.syntacticTwinBridges.length, greaterThanOrEqualTo(5));
      expect(profile.hasSyntacticTwinRule('V2 Rule'), isTrue);
      expect(profile.hasSyntacticTwinRule('Subordinate Verb-Final'), isTrue);
      expect(profile.hasSyntacticTwinRule('Separable Verbs'), isTrue);
      expect(profile.hasSyntacticTwinRule('Satzklammer'), isTrue);
    });

    test('False friend mitigation warns against deceptive cognates', () {
      expect(profile.falseFriendMitigation.keys, contains('bellen'));
      expect(profile.falseFriendMitigation.keys, contains('monster'));
      expect(profile.falseFriendMitigation.keys, contains('slim'));
    });

    test('Phonetic bridge identifies native match for letter G/CH to ach-Laut', () {
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('ach-Laut')).having((entry) => entry.value, 'value', contains('100% Native Identity'))));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('t+s')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Sister Language Acceleration')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('hallo / goedendag / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('moskee'));
      expect(profile.coreA1Vocabulary['Dank u wel / Heel erg bedankt'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
