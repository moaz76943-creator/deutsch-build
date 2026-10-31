import 'package:test/test.dart';
import '../../../lib/src/localization/profiles/arabic_deep_localization_profile.dart';

void main() {
  group('ArabicDeepLocalizationProfile Unit Tests (Task 401)', () {
    test('Contains vital contrastive phonemes (p vs b, v vs f, ü, ich-Laut)', () {
      expect(ArabicDeepLocalizationProfile.isRtl, isTrue);
      expect(ArabicDeepLocalizationProfile.localeCode, equals('ar'));
      expect(ArabicDeepLocalizationProfile.contrastivePhonemes.length, greaterThanOrEqualTo(4));

      final pPhoneme = ArabicDeepLocalizationProfile.contrastivePhonemes.firstWhere((p) => p.germanPhonemeIpa == '/p/');
      expect(pPhoneme.requiresSpecialTraining, isTrue);
      expect(pPhoneme.articulatoryGuidanceAr, contains('حبس الهواء خلف الشفتين'));
    });

    test('Normalizes Arabic diacritics and hamzas accurately', () {
      const textWithTashkeel = 'العَرَبِيَّةُ الصَّحِيحَةُ';
      final clean = ArabicDeepLocalizationProfile.normalizeArabicText(textWithTashkeel);
      expect(clean, equals('العربية الصحيحة'));
    });
  });
}
