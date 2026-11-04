import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/hausa_deep_localization_profile.dart';

void main() {
  group('HausaDeepLocalizationProfile Tests', () {
    const profile = HausaDeepLocalizationProfile();

    test('Metadata and linguistic properties are accurately configured', () {
      expect(profile.languageName, equals('Hausa'));
      expect(profile.iso6391, equals('ha'));
      expect(profile.iso6392, equals('hau'));
      expect(profile.languageFamily, equals('Afroasiatic'));
      expect(profile.branch, contains('Chadic'));
      expect(profile.writingDirection, equals('ltr'));
      expect(profile.specialCharacters, contains('ɓ'));
      expect(profile.specialCharacters, contains('ɗ'));
      expect(profile.specialCharacters, contains('ƙ'));
      expect(profile.specialCharacters, contains('ƴ'));
      expect(profile.hasTones, isTrue);
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.wordOrder, equals('SVO'));
    });

    test('Arabic-Islamic loanword dictionary holds authentic entries', () {
      expect(profile.isArabicLoanword("addu'a"), isTrue);
      expect(profile.isArabicLoanword('salla'), isTrue);
      expect(profile.isArabicLoanword('halal'), isTrue);
      expect(profile.isArabicLoanword('alkali'), isTrue);
      expect(profile.isArabicLoanword('computer'), isFalse);
    });

    test('German case mapping aligns with Hausa syntactic structures', () {
      expect(profile.grammaticalCaseMapping, containsPair('Nominativ', isNotEmpty));
      expect(profile.grammaticalCaseMapping, containsPair('Akkusativ', isNotEmpty));
      expect(profile.grammaticalCaseMapping, containsPair('Dativ', isNotEmpty));
      expect(profile.grammaticalCaseMapping, containsPair('Genitiv', isNotEmpty));
    });

    test('Phonetic bridge covers German umlauts and fricatives', () {
      expect(profile.containsPhoneticBridge('sch'), isTrue);
      expect(profile.containsPhoneticBridge('ö'), isTrue);
      expect(profile.containsPhoneticBridge('z'), isTrue);
    });

    test('Core vocabulary and dialogue samples are populated and halal', () {
      expect(profile.translateToGerman('Sannu'), equals('Hallo / Guten Tag'));
      expect(profile.translateToGerman('Na gode'), equals('Danke'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
      expect(profile.practicalDialoguePhrases.first['german'], contains('wie heißt du'));
    });
  });
}
