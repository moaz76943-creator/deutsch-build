import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/localization/profiles/somali_deep_localization_profile.dart';

void main() {
  group('SomaliDeepLocalizationProfile Unit Tests (Task 409)', () {
    test('Contains Somali suffixed article bridges and V2 word order guidance', () {
      expect(SomaliDeepLocalizationProfile.isRtl, isFalse);
      expect(SomaliDeepLocalizationProfile.localeCode, equals('so'));
      expect(SomaliDeepLocalizationProfile.articleBridges.length, equals(2));

      final masc = SomaliDeepLocalizationProfile.articleBridges.first;
      expect(masc.somaliSuffix, contains('-ka'));
      expect(masc.pedagogicalNoteSo, contains('Jarmalka'));

      final guidance = SomaliDeepLocalizationProfile.getSomaliWordOrderGuidance();
      expect(guidance, contains('Ich esse heute einen Apfel'));
    });
  });
}
