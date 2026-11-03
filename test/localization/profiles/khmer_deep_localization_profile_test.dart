import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/src/localization/profiles/khmer_deep_localization_profile.dart';
import 'package:deutsch_bilarabi/src/localization/matrix/universal_cross_lingual_matrix.dart';

void main() {
  group('KhmerDeepLocalizationProfile Tests', () {
    const profile = KhmerDeepLocalizationProfile();

    test('Linguistic properties correctly model Mon-Khmer standard', () {
      expect(profile.languageName, equals('Khmer'));
      expect(profile.iso6391, equals('km'));
      expect(profile.iso6392or3, equals('khm'));
      expect(profile.typology, equals(TypologicalClassification.isolatingAnalytic));
      expect(profile.primaryWordOrder, equals(CanonicalWordOrder.svo));
      expect(profile.hasTones, isFalse);
      expect(profile.totalScriptGlyphs, equals(74));
      expect(profile.hasGrammaticalGender, isFalse);
    });

    test('Case and register phonology alignment bridges are established', () {
      expect(profile.registerPhonologyBridge.keys, contains(contains('First Series')));
      expect(profile.registerPhonologyBridge.keys, contains(contains('Second Series')));
      expect(profile.getGermanCaseBridge('Dativ'), contains('Dativ'));
      expect(profile.getGermanCaseBridge('Genitiv'), contains('Genitiv'));
    });

    test('Cultural lexicon and A1 vocabulary are verified and halal', () {
      expect(profile.culturalIslamicLexicon.keys, contains('ជំរាបសួរ / សួស្តី / សាឡាម'));
      expect(profile.culturalIslamicLexicon.keys, contains('ហាឡាល់'));
      expect(profile.culturalIslamicLexicon.keys, contains('វិហារអ៊ីស្លាម / ម៉ัสជิด'));
      expect(profile.coreA1Vocabulary['អរគុណច្រើន'], equals('Vielen Dank'));
      expect(profile.practicalDialoguePhrases.length, greaterThanOrEqualTo(4));
    });
  });
}
