import 'package:test/test.dart';
import 'package:deutsch_app/core/language/language_readiness_guard.dart';

void main() {
  group('LanguageReadinessGuard Null-Safety Tests', () {
    late LanguageReadinessGuard guard;

    setUp(() {
      guard = const LanguageReadinessGuard({
        'de': LanguageReadinessInfo(
          languageCode: 'de',
          tier: LanguageSupportTier.productionReady,
          hasOfflineContent: true,
          hasVoicePack: true,
        ),
        'ar': LanguageReadinessInfo(
          languageCode: 'ar',
          tier: LanguageSupportTier.productionReady,
          hasOfflineContent: true,
          hasVoicePack: true,
        ),
        'la': LanguageReadinessInfo(
          languageCode: 'la', // Latin: experimental candidate
          tier: LanguageSupportTier.candidateBeta,
          hasOfflineContent: false,
          hasVoicePack: false,
        ),
      });
    });

    test('Returns safe fallback for null or empty language code without throwing', () {
      final nullResult = guard.resolveLanguage(null);
      expect(nullResult.tier, equals(LanguageSupportTier.unsupported));
      expect(nullResult.isInteractive, isFalse);

      final emptyResult = guard.resolveLanguage('   ');
      expect(emptyResult.tier, equals(LanguageSupportTier.unsupported));
    });

    test('Correctly permits production ready pairs and rejects incomplete pairs safely', () {
      // Production ready German-Arabic pair
      expect(guard.canActivatePair('de', 'ar'), isTrue);

      // Incomplete pair containing Latin (lacks offline content)
      expect(guard.canActivatePair('de', 'la'), isFalse);

      // Completely unknown language code
      expect(guard.canActivatePair('de', 'xyz'), isFalse);
    });
  });
}
