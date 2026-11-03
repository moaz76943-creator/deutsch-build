import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/basque_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('BasqueDeepLocalizationProfile Tests', () {
    const profile = BasqueDeepLocalizationProfile();

    test('Linguistic properties correctly model Basque language isolate', () {
      expect(profile.languageName, equals('Basque'));
      expect(profile.iso6391, equals('eu'));
      expect(profile.iso6392or3, equals('eus'));
      expect(profile.typology, equals(TypologicalClassification.agglutinative));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.sov));
      expect(profile.alignment, equals(GrammaticalAlignment.ergativeAbsolutive));
      expect(profile.nominalCaseCount, equals(17));
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Omnidirectional universal roles and IPA phonetics are verified', () {
      expect(profile.universalRoleMapping[UniversalGrammaticalRole.subjectOrAgent], contains('Ergatiboa'));
      expect(profile.universalRoleMapping[UniversalGrammaticalRole.directObjectOrPatient], contains('Absolutiboa'));
      expect(profile.universalRoleMapping[UniversalGrammaticalRole.indirectObjectOrRecipient], contains('Datiboa'));
      expect(profile.ipaPhoneticInventory.keys, contains('tx /tʃ/'));
      expect(profile.ipaPhoneticInventory.keys, contains('tz /ts̻/'));
    });

    test('Universal lexicon and dialogue samples are verified and halal', () {
      expect(profile.universalLexicon['greeting'], equals('Kaixo / Agur'));
      expect(profile.universalLexicon['halal'], contains('Halal'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
