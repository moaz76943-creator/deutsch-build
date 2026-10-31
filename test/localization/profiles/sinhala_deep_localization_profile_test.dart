import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/sinhala_deep_localization_profile.dart';

void main() {
  group('SinhalaDeepLocalizationProfile Tests', () {
    const profile = SinhalaDeepLocalizationProfile();

    test('Linguistic properties correctly model Insular Indo-Aryan Sinhala', () {
      expect(profile.languageName, equals('Sinhala'));
      expect(profile.iso6391, equals('si'));
      expect(profile.iso6392, equals('sin'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Insular'));
      expect(profile.hasAnimateInanimateDistinction, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.prenasalizedStops.length, equals(4));
      expect(profile.prenasalizedStops, contains('ඟ'));
      expect(profile.prenasalizedStops, contains('ඹ'));
    });

    test('Case system alignment maps 7 cases to German prepositions & declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Prathama'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Dvitiya'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Tritiya'), contains('mit'));
      expect(profile.getGermanCaseBridge('Chaturthi'), contains('zu'));
    });

    test('Phonetic bridge accurately assists German sound acquisition', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('ශ')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('ත්+ස්')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Prenasalized Stop'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('ආයුබෝවන් / සලාම්'));
      expect(profile.culturalIslamicLexicon, containsKey('හලාල්'));
      expect(profile.culturalIslamicLexicon, containsKey('නමස්කාරය / සලාත්'));
      expect(profile.coreA1Vocabulary['බොහෝම ස්තූතියි'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
