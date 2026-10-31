import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/nepali_deep_localization_profile.dart';

void main() {
  group('NepaliDeepLocalizationProfile Tests', () {
    const profile = NepaliDeepLocalizationProfile();

    test('Linguistic properties correctly model Pahari Indo-Aryan Nepali', () {
      expect(profile.languageName, equals('Nepali'));
      expect(profile.iso6391, equals('ne'));
      expect(profile.iso6392, equals('nep'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Northern zone'));
      expect(profile.hasErgativeMarker, isTrue);
      expect(profile.hasFormalPronounDistinction, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.honorificPronounBridge, containsPair(contains('Tapaaĩ'), contains('Sie')));
      expect(profile.honorificPronounBridge, containsPair(contains('Timi'), contains('du')));
    });

    test('Case system alignment maps 7 cases to German prepositions & declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Prathama'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Dvitiya'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Tritiya'), contains('mit'));
      expect(profile.getGermanCaseBridge('Panchami'), contains('aus'));
    });

    test('Phonetic bridge accurately assists German sound acquisition', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('श')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('त्+स')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Honorific Register'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('नमस्ते / सलाम'));
      expect(profile.culturalIslamicLexicon, containsKey('हलाल / शुद्ध'));
      expect(profile.culturalIslamicLexicon, containsKey('नमाज / प्रार्थना'));
      expect(profile.coreA1Vocabulary['धेरै धेरै धन्यवाद'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
