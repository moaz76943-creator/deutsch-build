import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/greek_deep_localization_profile.dart';

void main() {
  group('GreekDeepLocalizationProfile Tests', () {
    const profile = GreekDeepLocalizationProfile();

    test('Linguistic properties correctly model Hellenic Greek standard', () {
      expect(profile.languageName, equals('Greek'));
      expect(profile.iso6391, equals('el'));
      expect(profile.iso6392, equals('ell'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, equals('Hellenic'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.hasExactPreposedArticleMirror, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.articleEquivalenceMap.length, equals(3));
      expect(profile.articleEquivalenceMap, containsPair(contains('Ο / ο'), contains('der')));
      expect(profile.articleEquivalenceMap, containsPair(contains('Η / η'), contains('die')));
      expect(profile.articleEquivalenceMap, containsPair(contains('Το / το'), contains('das')));
    });

    test('Case system alignment maps 4 Greek cases and Dative bridge to German', () {
      expect(profile.caseSystemAlignment.length, equals(5));
      expect(profile.getGermanCaseBridge('Ονομαστική'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Γενική'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Αιτιατική'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Dative'), contains('Dativ'));
    });

    test('Phonetic bridge identifies native matches for both ach-Laut and ich-Laut in Greek Χ', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ch /x/ (ach-Laut)', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('ch /ç/ (ich-Laut)', contains('100% Native Identity')));
      expect(profile.grecoGermanCognateBridges, containsPair(contains('philosophia'), contains('Philosophie')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('γεια σας / σελάμ'));
      expect(profile.culturalIslamicLexicon, containsKey('χαλάλ'));
      expect(profile.culturalIslamicLexicon, containsKey('τζαμί'));
      expect(profile.coreA1Vocabulary['Ευχαριστώ πολύ'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
