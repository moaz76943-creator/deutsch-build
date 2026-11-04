import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/welsh_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('WelshDeepLocalizationProfile Tests', () {
    const profile = WelshDeepLocalizationProfile();

    test('Linguistic properties correctly model Brythonic Welsh standard', () {
      expect(profile.languageName, equals('Welsh'));
      expect(profile.iso6391, equals('cy'));
      expect(profile.iso6392or3, equals('cym'));
      expect(profile.typology, equals(TypologicalClassification.fusionalInflected));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.vso));
      expect(profile.hasGrammaticalGender, isTrue);
      expect(profile.specialDigraphs, contains('ll'));
      expect(profile.specialDigraphs, contains('dd'));
      expect(profile.specialDigraphs, contains('ch'));
    });

    test('Initial mutations and universal roles are established', () {
      expect(profile.ipaPhoneticInventory.keys, contains(contains('Soft Mutation')));
      expect(profile.ipaPhoneticInventory.keys, contains(contains('Nasal Mutation')));
      expect(profile.ipaPhoneticInventory.keys, contains(contains('Aspirate Mutation')));
      expect(profile.universalRoleMapping[UniversalGrammaticalRole.subjectOrAgent], contains('Goddrych'));
    });

    test('Universal lexicon and dialogue samples are verified and halal', () {
      expect(profile.universalLexicon['greeting'], contains('Shwmae'));
      expect(profile.universalLexicon['halal'], contains('Halal'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
