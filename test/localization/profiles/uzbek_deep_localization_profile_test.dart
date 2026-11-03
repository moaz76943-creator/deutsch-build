import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/uzbek_deep_localization_profile.dart';

void main() {
  group('UzbekDeepLocalizationProfile Tests', () {
    const profile = UzbekDeepLocalizationProfile();

    test('Linguistic and typological metadata conform to standard Uzbek', () {
      expect(profile.languageName, equals('Uzbek'));
      expect(profile.iso6391, equals('uz'));
      expect(profile.iso6392, equals('uzb'));
      expect(profile.languageFamily, equals('Turkic'));
      expect(profile.branch, contains('Karluk'));
      expect(profile.isAgglutinative, isTrue);
      expect(profile.hasVowelHarmony, isFalse); // Unique trait among Turkic
      expect(profile.hasGrammaticalGender, isFalse);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains("o'"));
      expect(profile.specialCharacters, contains("g'"));
    });

    test('Case system alignment links 6 Uzbek cases to German equivalents', () {
      expect(profile.caseSystemAlignment.length, equals(6));
      // Native locative/ablative cases map to German prepositions with Dativ;
      // German itself has four cases, without a Lokativ or Ablativ case.
      expect(profile.getGermanCaseBridge('Tushum'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Qaratqich'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Joʻnalish'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Oʻrin-payt'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Chiqish'), contains('Dativ'));
    });

    test('Cultural and Islamic lexicon contains verified shared heritage', () {
      expect(profile.isSharedCulturalTerm('salom'), isTrue);
      expect(profile.isSharedCulturalTerm('kitob'), isTrue);
      expect(profile.isSharedCulturalTerm('halol'), isTrue);
      expect(profile.isSharedCulturalTerm('adolat'), isTrue);
      expect(profile.isSharedCulturalTerm('automobile'), isFalse);
    });

    test('Phonetic bridge accurately assists German sound acquisition', () {
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('ach-Laut')).having((entry) => entry.value, 'value', contains('yaxshi'))));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('/ts/')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Dialogue and core vocabulary are complete and high quality', () {
      expect(profile.coreA1Vocabulary['Assalomu alaykum'], contains('Guten Tag'));
      expect(profile.coreA1Vocabulary['Katta rahmat'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
