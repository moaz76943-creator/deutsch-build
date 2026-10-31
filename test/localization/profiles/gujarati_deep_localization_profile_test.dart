import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/gujarati_deep_localization_profile.dart';

void main() {
  group('GujaratiDeepLocalizationProfile Tests', () {
    const profile = GujaratiDeepLocalizationProfile();

    test('Linguistic properties correctly highlight 3-gender Indo-Aryan system', () {
      expect(profile.languageName, equals('Gujarati'));
      expect(profile.iso6391, equals('gu'));
      expect(profile.iso6392, equals('guj'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Indo-Aryan'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.matchesGermanThreeGenders(), isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.genderEquivalenceMap, containsPair(contains('Puling'), contains('Maskulinum')));
      expect(profile.genderEquivalenceMap, containsPair(contains('Striling'), contains('Femininum')));
      expect(profile.genderEquivalenceMap, containsPair(contains('Napunsakling'), contains('Neutrum')));
    });

    test('Phonetic bridge accurately assists German sound acquisition', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('શ')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('ત્સ')));
      expect(profile.germanPhoneticBridges, containsPair(contains('3-Gender'), isNotEmpty));
    });

    test('Case system alignment links postpositions to German cases', () {
      expect(profile.caseSystemAlignment, containsPair(contains('Direct'), contains('Nominativ')));
      expect(profile.caseSystemAlignment, containsPair(contains('Genitive'), contains('Genitiv')));
      expect(profile.caseSystemAlignment, containsPair(contains('Locative'), contains('in')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('સલામ'));
      expect(profile.culturalIslamicLexicon, containsKey('હલાલ'));
      expect(profile.culturalIslamicLexicon, containsKey('નમાઝ'));
      expect(profile.coreA1Vocabulary['ખૂબ ખૂબ આભાર'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
