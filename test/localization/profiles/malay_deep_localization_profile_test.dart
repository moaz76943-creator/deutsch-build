import 'package:test/test.dart';
import '../../../lib/src/localization/profiles/malay_deep_localization_profile.dart';

void main() {
  group('MalayDeepLocalizationProfile Unit Tests (Task 406)', () {
    test('Contains SVO syntax confirmation and Malay reduplication contrastive guidance', () {
      expect(MalayDeepLocalizationProfile.isRtl, isFalse);
      expect(MalayDeepLocalizationProfile.localeCode, equals('ms'));
      expect(MalayDeepLocalizationProfile.hasSharedMainClauseSvoOrder(), isTrue);

      final pluralGuidance = MalayDeepLocalizationProfile.getPluralFormationGuidance();
      expect(pluralGuidance, contains('buku-buku'));
      expect(pluralGuidance, contains('die Bücher'));
    });
  });
}
