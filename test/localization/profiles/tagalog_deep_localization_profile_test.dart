import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/tagalog_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('TagalogDeepLocalizationProfile Tests', () {
    const profile = TagalogDeepLocalizationProfile();

    test('Linguistic properties correctly model Austronesian Tagalog standard', () {
      expect(profile.languageName, equals('Tagalog'));
      expect(profile.iso6391, equals('tl'));
      expect(profile.iso6392or3, equals('fil'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.vso));
      expect(profile.alignment, equals(GrammaticalAlignment.austronesianSymmetricVoice));
      expect(profile.hasTones, isFalse);
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Voice focus system and particle alignment are accurately configured', () {
      expect(profile.voiceFocusSystemAlignment.length, greaterThanOrEqualTo(5));
      expect(profile.voiceFocusSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Actor Focus')).having((entry) => entry.value, 'value', contains('active voice'))));
      expect(profile.voiceFocusSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Patient/Object')).having((entry) => entry.value, 'value', contains('Akkusativ'))));
      expect(profile.voiceFocusSystemAlignment.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Particle "ng"')).having((entry) => entry.value, 'value', contains('Genitiv'))));
    });

    test('Omnidirectional cross-lingual transfer matrix is established', () {
      expect(profile.omnidirectionalBridges.keys, contains(contains('Austronesian Western Matrix')));
      expect(profile.omnidirectionalBridges.keys, contains(contains('Hispanic Romance')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('kamusta / salam'));
      expect(profile.culturalIslamicLexicon.keys, contains('halal'));
      expect(profile.culturalIslamicLexicon.keys, contains('salamat / maraming salamat'));
      expect(profile.culturalIslamicLexicon.keys, contains('moske / masjid'));
      expect(profile.coreA1Vocabulary['Maraming salamat'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
