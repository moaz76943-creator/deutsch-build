import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/localization/profiles/swahili_deep_localization_profile.dart';

void main() {
  group('SwahiliDeepLocalizationProfile Unit Tests (Task 407)', () {
    test('Contains Swahili noun class bridges (Ngeli) and SVO syntax alignment', () {
      expect(SwahiliDeepLocalizationProfile.isRtl, isFalse);
      expect(SwahiliDeepLocalizationProfile.localeCode, equals('sw'));
      expect(SwahiliDeepLocalizationProfile.hasSharedSvoOrder(), isTrue);
      expect(SwahiliDeepLocalizationProfile.nounClassBridges.length, equals(2));

      final mwa = SwahiliDeepLocalizationProfile.nounClassBridges.first;
      expect(mwa.swahiliNounClass, contains('M-WA'));
      expect(mwa.pedagogicalExplanationSw, contains('Kijerumani'));
    });
  });
}
