import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/circassian_deep_localization_profile.dart';

void main() {
  group('CircassianDeepLocalizationProfile Tests', () {
    const profile = CircassianDeepLocalizationProfile();

    test('Linguistic properties correctly model Northwest Caucasian Circassian standard', () {
      expect(profile.languageName, equals('Circassian'));
      expect(profile.iso6391, equals('ady'));
      expect(profile.iso6392, equals('ady'));
      expect(profile.languageFamily, equals('Northwest Caucasian'));
      expect(profile.branch, equals('Circassian'));
      expect(profile.hasErgativeAlignment, isTrue);
      expect(profile.isPolysynthetic, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('Ӏ'));
      expect(profile.specialCharacters, contains('лъ'));
      expect(profile.specialCharacters, contains('цӏ'));
    });

    test('Case system alignment maps 4 Circassian cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(4));
      expect(profile.getGermanCaseBridge('Абсолютив'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Эргатив'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Творительнэ'), contains('mit'));
      expect(profile.getGermanCaseBridge('Превратительнэ'), contains('als'));
    });

    test('Phonetic bridge identifies native match for letter Ц to German Z', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Ш')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Consonant Acuity')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('шъуфэсакъ / салам'));
      expect(profile.culturalIslamicLexicon.keys, contains('хьэлял'));
      expect(profile.culturalIslamicLexicon.keys, contains('тхьэлъэӏу / нэмэз'));
      expect(profile.culturalIslamicLexicon.keys, contains('мэщыт'));
      expect(profile.coreA1Vocabulary['Тхьауегъэпсэу'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
