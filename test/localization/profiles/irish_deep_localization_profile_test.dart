import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/irish_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('IrishDeepLocalizationProfile Tests', () {
    const profile = IrishDeepLocalizationProfile();

    test('Linguistic properties correctly model Goidelic Irish standard', () {
      expect(profile.languageName, equals('Irish'));
      expect(profile.iso6391, equals('ga'));
      expect(profile.iso6392or3, equals('gle'));
      expect(profile.typology, equals(TypologicalClassification.fusionalInflected));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.vso));
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.fadaVowels, contains('á'));
      expect(profile.fadaVowels, contains('ú'));
    });

    test('Initial mutations and universal roles are established', () {
      expect(profile.ipaPhoneticInventory.keys, contains(contains('Séimhiú')));
      expect(profile.ipaPhoneticInventory.keys, contains(contains('Urú')));
      expect(profile.universalRoleMapping[UniversalGrammaticalRole.subjectOrAgent], contains('Ainmneach'));
      expect(profile.universalRoleMapping[UniversalGrammaticalRole.genitivePossessor], contains('Ginideach'));
    });

    test('Universal lexicon and dialogue samples are verified and halal', () {
      expect(profile.universalLexicon['greeting'], contains('Dia dhuit'));
      expect(profile.universalLexicon['halal'], contains('Halal'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
