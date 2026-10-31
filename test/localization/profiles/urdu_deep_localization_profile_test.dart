import 'package:test/test.dart';
import '../../../lib/src/localization/profiles/urdu_deep_localization_profile.dart';

void main() {
  group('UrduDeepLocalizationProfile Unit Tests (Task 404)', () {
    test('Contains RTL flag, Nastaliq font preference, and 4 German case equivalents in Urdu', () {
      expect(UrduDeepLocalizationProfile.isRtl, isTrue);
      expect(UrduDeepLocalizationProfile.localeCode, equals('ur'));
      expect(UrduDeepLocalizationProfile.preferredFont, equals('NotoNastaliqUrdu'));
      expect(UrduDeepLocalizationProfile.caseEquivalentsUrdu.length, equals(4));

      final accusative = UrduDeepLocalizationProfile.caseEquivalentsUrdu['Accusative (den/die/das)'];
      expect(accusative, contains('مفعولی حالت'));
    });

    test('Provides clear V2 word order pedagogical guidance in Urdu', () {
      final guidance = UrduDeepLocalizationProfile.getWordOrderGuidance();
      expect(guidance, contains('Ich lese das Buch'));
      expect(guidance, contains('V2 Rule'));
    });
  });
}
