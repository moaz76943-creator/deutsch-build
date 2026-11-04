import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/lao_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('LaoDeepLocalizationProfile Tests', () {
    const profile = LaoDeepLocalizationProfile();

    test('Linguistic properties correctly model Kra-Dai Lao standard', () {
      expect(profile.languageName, equals('Lao'));
      expect(profile.iso6391, equals('lo'));
      expect(profile.iso6392or3, equals('lao'));
      expect(profile.typology, equals(TypologicalClassification.isolatingAnalytic));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isTrue);
      expect(profile.toneCount, equals(6));
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Isolating prepositional case bridge is established', () {
      expect(profile.isolatingCaseBridge.length, greaterThanOrEqualTo(5));
      expect(profile.isolatingCaseBridge.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Genitiv')).having((entry) => entry.value, 'value', contains('Genitiv'))));
      expect(profile.isolatingCaseBridge.entries, contains(isA<MapEntry<String, String>>().having((entry) => entry.key, 'key', contains('Dativ')).having((entry) => entry.value, 'value', contains('Dativ'))));
      expect(profile.germanPhoneticBridges, containsPair('tsch /tʃ/', contains('ຈ')));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('ສະບາຍດີ / ຊາລາມ'));
      expect(profile.culturalIslamicLexicon.keys, contains('ຮາລານ'));
      expect(profile.culturalIslamicLexicon.keys, contains('ມັດສະຍິດ'));
      expect(profile.coreA1Vocabulary['ຂອບໃຈຫຼາຍໆ'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
