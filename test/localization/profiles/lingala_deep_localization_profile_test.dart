import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/lingala_deep_localization_profile.dart';
import 'package:deutsch_build/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('LingalaDeepLocalizationProfile Tests', () {
    const profile = LingalaDeepLocalizationProfile();

    test('Linguistic properties correctly model Central Bantu Lingala standard', () {
      expect(profile.languageName, equals('Lingala'));
      expect(profile.iso6391, equals('ln'));
      expect(profile.iso6392or3, equals('lin'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isTrue);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.nounClassCount, equals(15));
      expect(profile.specialVowels, contains('ɛ'));
      expect(profile.specialVowels, contains('ɔ'));
    });

    test('Paired noun class bridge and preposition traits are verified', () {
      expect(profile.nounClassPairBridge, containsKey(contains('Paired Noun')));
      expect(profile.nounClassPairBridge, containsKey(contains('Prepositional')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Pitch Modulation'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('mbote / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('ndako ya nzambe / misiti'));
      expect(profile.coreA1Vocabulary['Matondi mingi'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
