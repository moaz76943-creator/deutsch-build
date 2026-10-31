import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/georgian_deep_localization_profile.dart';

void main() {
  group('GeorgianDeepLocalizationProfile Tests', () {
    const profile = GeorgianDeepLocalizationProfile();

    test('Linguistic properties correctly model Kartvelian Georgian standard', () {
      expect(profile.languageName, equals('Georgian'));
      expect(profile.iso6391, equals('ka'));
      expect(profile.iso6392, equals('kat'));
      expect(profile.languageFamily, equals('Kartvelian'));
      expect(profile.branch, contains('Karto-Zan'));
      expect(profile.hasSplitErgativity, isTrue);
      expect(profile.hasPolypersonalVerbs, isTrue);
      expect(profile.primaryScript, contains('Mkhedruli'));
    });

    test('Case system alignment maps 7 Georgian cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('სახელობითი'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('ნათესაობითი'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('მიცემითი'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('მოქმედებითი'), contains('mit'));
      expect(profile.getGermanCaseBridge('ვითარებითი'), contains('als'));
    });

    test('Phonetic bridge identifies native match for letter ც to German Z', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('შ')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('ჩ')));
      expect(profile.germanPhoneticBridges, containsPair(contains('ach-Laut'), contains('ხ')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('გამარჯობა / სალამ'));
      expect(profile.culturalIslamicLexicon, containsKey('ჰალალი'));
      expect(profile.culturalIslamicLexicon, containsKey('ლოცვა / ნამაზი'));
      expect(profile.coreA1Vocabulary['დიდი მადლობა'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
