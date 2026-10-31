import 'package:test/test.dart';
import '../../../lib/src/localization/profiles/turkish_deep_localization_profile.dart';

void main() {
  group('TurkishDeepLocalizationProfile Unit Tests (Task 402)', () {
    test('Correctly classifies 2-way Turkish vowel harmony', () {
      expect(TurkishDeepLocalizationProfile.classifyVowelHarmony('evler'), equals(VowelClass.front));
      expect(TurkishDeepLocalizationProfile.classifyVowelHarmony('kitaplar'), equals(VowelClass.back));
      expect(TurkishDeepLocalizationProfile.isRtl, isFalse);
    });

    test('Provides clear V2 syntactic transfer explanation for German learning', () {
      final warning = TurkishDeepLocalizationProfile.getSyntacticTransferWarning();
      expect(warning, contains('V2 kuralı'));
      expect(warning, contains('Ich esse heute einen Apfel'));
    });
  });
}
