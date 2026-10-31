import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/bulgarian_deep_localization_profile.dart';

void main() {
  group('BulgarianDeepLocalizationProfile Tests', () {
    const profile = BulgarianDeepLocalizationProfile();

    test('Linguistic properties correctly model South Slavic analytical Bulgarian', () {
      expect(profile.languageName, equals('Bulgarian'));
      expect(profile.iso6391, equals('bg'));
      expect(profile.iso6392, equals('bul'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('South Slavic'));
      expect(profile.hasThreeGenders, isTrue);
      expect(profile.isAnalytical, isTrue);
      expect(profile.hasPostposedDefiniteArticles, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.specialCharacters, contains('ъ'));
      expect(profile.genderEquivalenceMap.length, equals(3));
    });

    test('Analytical case bridges map prepositional structures to German cases', () {
      expect(profile.analyticalCaseBridge.length, equals(6));
      expect(profile.getGermanCaseBridge('Nominativ'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Instrumentalis'), contains('mit'));
    });

    test('Phonetic bridge identifies native match for letter Ц to German Z', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Ш')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Ч')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Article Inversion'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('добър ден / селям'));
      expect(profile.culturalIslamicLexicon, containsKey('халал'));
      expect(profile.culturalIslamicLexicon, containsKey('джамия'));
      expect(profile.coreA1Vocabulary['Благодаря много'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
