import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/avar_deep_localization_profile.dart';

void main() {
  group('AvarDeepLocalizationProfile Tests', () {
    const profile = AvarDeepLocalizationProfile();

    test('Linguistic properties correctly model Avar-Andic standard', () {
      expect(profile.languageName, equals('Avar'));
      expect(profile.iso6391, equals('av'));
      expect(profile.iso6392, equals('ava'));
      expect(profile.languageFamily, equals('Northeast Caucasian'));
      expect(profile.branch, equals('Avar-Andic'));
      expect(profile.hasErgativeAlignment, isTrue);
      expect(profile.hasSpatialCaseMatrix, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('ӏ'));
      expect(profile.specialCharacters, contains('гӏ'));
      expect(profile.specialCharacters, contains('хӏ'));
    });

    test('Case system alignment maps 8 core cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(8));
      expect(profile.getGermanCaseBridge('Тӏоцебесеб'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Хаслъул'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Кьовул'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Локатив I'), contains('in'));
      expect(profile.getGermanCaseBridge('Аблатив'), contains('aus'));
    });

    test('Phonetic bridge identifies native match for letter Ц to German Z', () {
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Ш')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Spatial Case Matrix'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('салам / ворчӏами'));
      expect(profile.culturalIslamicLexicon, containsKey('хӏалал'));
      expect(profile.culturalIslamicLexicon, containsKey('как / намаз'));
      expect(profile.culturalIslamicLexicon, containsKey('мажгит'));
      expect(profile.coreA1Vocabulary['Кӏудияб баркала'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
