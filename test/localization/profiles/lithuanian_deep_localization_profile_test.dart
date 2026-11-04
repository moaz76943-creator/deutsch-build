import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/lithuanian_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('LithuanianDeepLocalizationProfile Tests', () {
    const profile = LithuanianDeepLocalizationProfile();

    test('Linguistic properties correctly model Baltic Lithuanian standard', () {
      expect(profile.languageName, equals('Lithuanian'));
      expect(profile.iso6391, equals('lt'));
      expect(profile.iso6392or3, equals('lit'));
      expect(profile.typology, equals(TypologicalClassification.fusionalInflected));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isTrue);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.specialCharacters, contains('ą'));
      expect(profile.specialCharacters, contains('č'));
      expect(profile.specialCharacters, contains('š'));
      expect(profile.specialCharacters, contains('ž'));
    });

    test('7-case system alignment maps directly to German declensions', () {
      expect(profile.sevenCaseSystemAlignment.length, equals(7));
      expect(profile.sevenCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Vardininkas')).having((entry) => entry.value, 'value', contains('Nominativ'))));
      expect(profile.sevenCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Kilmininkas')).having((entry) => entry.value, 'value', contains('Genitiv'))));
      expect(profile.sevenCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Naudininkas')).having((entry) => entry.value, 'value', contains('Dativ'))));
      expect(profile.sevenCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Galininkas')).having((entry) => entry.value, 'value', contains('Akkusativ'))));
      expect(profile.sevenCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Įnagininkas')).having((entry) => entry.value, 'value', contains('mit'))));
      expect(profile.sevenCaseSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Vietininkas')).having((entry) => entry.value, 'value', contains('in'))));
    });

    test('Phonetic bridge identifies 100% native matches for C, Š, and Č', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('100% Native Identity')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('labas / laba diena / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('mečetė'));
      expect(profile.coreA1Vocabulary['Labai ačiū'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
