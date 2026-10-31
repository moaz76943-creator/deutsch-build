import 'package:test/test.dart';
import '../../../lib/src/localization/profiles/bengali_deep_localization_profile.dart';

void main() {
  group('BengaliDeepLocalizationProfile Unit Tests (Task 408)', () {
    test('Contains Bengali honorific pronoun mappings (Apni -> Sie, Tumi -> du)', () {
      expect(BengaliDeepLocalizationProfile.isRtl, isFalse);
      expect(BengaliDeepLocalizationProfile.localeCode, equals('bn'));
      expect(BengaliDeepLocalizationProfile.honorifics.length, equals(2));

      final formal = BengaliDeepLocalizationProfile.honorifics.first;
      expect(formal.bengaliPronoun, contains('আপনি'));
      expect(formal.germanEquivalent, contains('Sie'));
    });

    test('Provides clear V2 syntactic transfer advice in Bengali script', () {
      final guidance = BengaliDeepLocalizationProfile.getBengaliSyntacticGuidance();
      expect(guidance, contains('Ich lese das Buch'));
      expect(guidance, contains('V2 Rule'));
    });
  });
}
