import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/portuguese_deep_localization_profile.dart';

void main() {
  group('PortugueseDeepLocalizationProfile Tests', () {
    const profile = PortugueseDeepLocalizationProfile();

    test('Linguistic properties correctly model Ibero-Romance Portuguese standard', () {
      expect(profile.languageName, equals('Portuguese'));
      expect(profile.iso6391, equals('pt'));
      expect(profile.iso6392, equals('por'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Romance'));
      expect(profile.hasTwoGenders, isTrue);
      expect(profile.hasSibilantPalatalization, isTrue);
      expect(profile.wordOrder, equals('SVO'));
      expect(profile.specialCharacters, contains('ã'));
      expect(profile.specialCharacters, contains('ç'));
    });

    test('Case and preposition alignment maps to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(6));
      expect(profile.getGermanCaseBridge('Nominativ'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Akkusativ'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Instrumentalis'), contains('mit'));
    });

    test('Phonetic bridge identifies native match for coda sibilants to German sch', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('100% Native Identity')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('t+s')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Personal Infinitive'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('olá / salam'));
      expect(profile.culturalIslamicLexicon, containsKey('halal'));
      expect(profile.culturalIslamicLexicon, containsKey('oxalá'));
      expect(profile.culturalIslamicLexicon, containsKey('mesquita'));
      expect(profile.coreA1Vocabulary['Muito obrigado'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
