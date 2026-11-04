import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/localization/profiles/indonesian_deep_localization_profile.dart';

void main() {
  group('IndonesianDeepLocalizationProfile Unit Tests (Task 405)', () {
    test('Contains SVO alignment and gender acquisition bridge for Indonesian learners', () {
      expect(IndonesianDeepLocalizationProfile.isRtl, isFalse);
      expect(IndonesianDeepLocalizationProfile.defaultWordOrder, equals('SVO'));
      expect(IndonesianDeepLocalizationProfile.localeCode, equals('id'));
      expect(IndonesianDeepLocalizationProfile.pedagogicalBridges.length, equals(2));

      final genderBridge = IndonesianDeepLocalizationProfile.pedagogicalBridges.first;
      expect(genderBridge.featureName, contains('Gender'));
      expect(genderBridge.strategyTipId, contains('Selalu hafalkan kata benda Jerman'));
    });
  });
}
