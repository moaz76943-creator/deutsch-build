import 'package:test/test.dart';
import 'package:deutsch_build/src/localization/profiles/assamese_deep_localization_profile.dart';

void main() {
  group('AssameseDeepLocalizationProfile Tests', () {
    const profile = AssameseDeepLocalizationProfile();

    test('Linguistic properties correctly model Eastern Indo-Aryan Assamese', () {
      expect(profile.languageName, equals('Assamese'));
      expect(profile.iso6391, equals('as'));
      expect(profile.iso6392, equals('asm'));
      expect(profile.languageFamily, equals('Indo-European'));
      expect(profile.branch, contains('Eastern zone'));
      expect(profile.hasNativeVelarFricativeX, isTrue);
      expect(profile.wordOrder, equals('SOV'));
      expect(profile.specialCharacters, contains('ৰ'));
      expect(profile.specialCharacters, contains('ৱ'));
    });

    test('Case system alignment maps 7 cases to German prepositions & declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Prathama'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Dvitiya'), contains('Akkusativ'));
      expect(profile.getGermanCaseBridge('Tritiya'), contains('mit'));
      expect(profile.getGermanCaseBridge('Panchami'), contains('aus'));
    });

    test('Phonetic bridge identifies native velar fricative /x/ for German ch', () {
      expect(profile.germanPhoneticBridges, containsPair(contains('ach-Laut'), contains('Native 1:1')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('ত+স')));
      expect(profile.germanPhoneticBridges, containsPair(contains('Classifier System'), isNotEmpty));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon, containsKey('নমস্কাৰ / ছালাম'));
      expect(profile.culturalIslamicLexicon, containsKey('হালাল'));
      expect(profile.culturalIslamicLexicon, containsKey('নমাজ'));
      expect(profile.coreA1Vocabulary['অশেষ ধন্যবাদ'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
