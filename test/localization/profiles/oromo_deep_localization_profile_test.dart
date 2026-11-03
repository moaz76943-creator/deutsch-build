import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/oromo_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('OromoDeepLocalizationProfile Tests', () {
    const profile = OromoDeepLocalizationProfile();

    test('Linguistic properties correctly model Cushitic Oromo standard', () {
      expect(profile.languageName, equals('Oromo'));
      expect(profile.iso6391, equals('om'));
      expect(profile.iso6392or3, equals('orm'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.sov));
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.primaryScript, contains('Qubee'));
      expect(profile.qubeeSpecialGraphemes, contains('dh'));
      expect(profile.qubeeSpecialGraphemes, contains('ny'));
    });

    test('Case system alignment maps 7 Oromo cases to German declensions', () {
      expect(profile.caseSystemAlignment.length, equals(7));
      expect(profile.getGermanCaseBridge('Nominativ'), contains('Nominativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Instrumentalis'), contains('mit'));
      expect(profile.getGermanCaseBridge('Ablativ'), contains('aus'));
    });

    test('Phonetic bridge identifies native matches and vowel quantity', () {
      expect(profile.germanPhoneticBridges, containsPair('sch /ʃ/', contains('Sh')));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('Ch')));
      expect(profile.germanPhoneticBridges, containsPair('z /ts/', contains('Ts')));
      expect(profile.germanPhoneticBridges.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Vowel Length')).having((entry) => entry.value, 'value', isNotEmpty)));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('akkam / nagaa / salaam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halaala'));
      expect(profile.culturalIslamicLexicon.keys, contains('masjiida'));
      expect(profile.coreA1Vocabulary['Baay\'ee galatoomi'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
