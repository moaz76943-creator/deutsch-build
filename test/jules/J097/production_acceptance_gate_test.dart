import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

class MockJ025StartupContract implements J025StartupContract {
  @override
  final bool hasNewDartErrors;
  @override
  final bool hasNormalStartup;
  @override
  final bool hasSafeModeStartup;
  @override
  final bool isLifecycleManaged;
  @override
  final bool isOfflineSafe;
  @override
  final bool isStorageGuarded;

  MockJ025StartupContract({
    this.hasNewDartErrors = false,
    this.hasNormalStartup = true,
    this.hasSafeModeStartup = true,
    this.isLifecycleManaged = true,
    this.isOfflineSafe = true,
    this.isStorageGuarded = true,
  });
}

class MockJ095VerificationResult implements J095VerificationResult {
  @override
  final bool hasMemoryRegression;
  @override
  final bool hasFTS5Regression;
  @override
  final bool isStorageCorrupt;
  @override
  final bool isEvidenceStale;
  @override
  final bool hasMissingMandatoryEvidence;

  MockJ095VerificationResult({
    this.hasMemoryRegression = false,
    this.hasFTS5Regression = false,
    this.isStorageCorrupt = false,
    this.isEvidenceStale = false,
    this.hasMissingMandatoryEvidence = false,
  });
}

class MockLanguageReadinessEvidence implements LanguageReadinessEvidence {
  @override
  final String languageCode;
  @override
  final bool hasLocalPackEvidence;
  @override
  final bool isMetadataOnly;

  MockLanguageReadinessEvidence({
    required this.languageCode,
    this.hasLocalPackEvidence = true,
    this.isMetadataOnly = false,
  });
}

class MockOptionalFeatureEvidence implements OptionalFeatureEvidence {
  @override
  final String featureName;
  @override
  final bool isAvailable;

  MockOptionalFeatureEvidence({
    required this.featureName,
    this.isAvailable = true,
  });
}

void main() {
  group('ProductionAcceptanceGate - Compatibility', () {
    test('verifyAppReadiness works as before', () {
      final ready = ProductionAcceptanceGate.verifyAppReadiness(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      expect(ready, isTrue);

      final notReady = ProductionAcceptanceGate.verifyAppReadiness(
        isOfflineSafe: false,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      expect(notReady, isFalse);
    });
  });

  group('ProductionAcceptanceGate - Enforceable Authority', () {
    test('missing contracts results in notVerified', () {
      final result1 = ProductionAcceptanceGate.evaluatePromotion();
      expect(result1, PromotionEligibility.notVerified);

      final result2 = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(),
      );
      expect(result2, PromotionEligibility.notVerified);
    });

    test('missing mandatory evidence or stale evidence results in notVerified', () {
      final result1 = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(),
        verificationResult: MockJ095VerificationResult(hasMissingMandatoryEvidence: true),
      );
      expect(result1, PromotionEligibility.notVerified);

      final result2 = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(),
        verificationResult: MockJ095VerificationResult(isEvidenceStale: true),
      );
      expect(result2, PromotionEligibility.notVerified);
    });

    test('new dart errors blocks promotion', () {
      final result = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(hasNewDartErrors: true),
        verificationResult: MockJ095VerificationResult(),
      );
      expect(result, PromotionEligibility.blocked);
    });

    test('missing normal or safe mode startup blocks promotion', () {
      final result1 = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(hasNormalStartup: false),
        verificationResult: MockJ095VerificationResult(),
      );
      expect(result1, PromotionEligibility.blocked);

      final result2 = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(hasSafeModeStartup: false),
        verificationResult: MockJ095VerificationResult(),
      );
      expect(result2, PromotionEligibility.blocked);
    });

    test('performance regressions block promotion', () {
      final result1 = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(),
        verificationResult: MockJ095VerificationResult(hasMemoryRegression: true),
      );
      expect(result1, PromotionEligibility.blocked);

      final result2 = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(),
        verificationResult: MockJ095VerificationResult(hasFTS5Regression: true),
      );
      expect(result2, PromotionEligibility.blocked);
    });

    test('corrupt storage blocks promotion', () {
      final result = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(),
        verificationResult: MockJ095VerificationResult(isStorageCorrupt: true),
      );
      expect(result, PromotionEligibility.blocked);
    });

    test('metadata-only language or missing local pack evidence blocks promotion', () {
      final result1 = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(),
        verificationResult: MockJ095VerificationResult(),
        languageEvidence: [MockLanguageReadinessEvidence(languageCode: 'en', isMetadataOnly: true)],
      );
      expect(result1, PromotionEligibility.blocked);

      final result2 = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(),
        verificationResult: MockJ095VerificationResult(),
        languageEvidence: [MockLanguageReadinessEvidence(languageCode: 'en', hasLocalPackEvidence: false)],
      );
      expect(result2, PromotionEligibility.blocked);
    });

    test('unavailable optional features degrades safely and preserves configuration', () {
      final initialConfig = ProductionAcceptanceGate.lastApprovedConfiguration;

      final result = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(),
        verificationResult: MockJ095VerificationResult(),
        languageEvidence: [MockLanguageReadinessEvidence(languageCode: 'ar')],
        optionalFeatures: [MockOptionalFeatureEvidence(featureName: 'tts', isAvailable: false)],
      );

      expect(result, PromotionEligibility.degraded);

      final updatedConfig = ProductionAcceptanceGate.lastApprovedConfiguration;
      expect(updatedConfig, isNotNull);
      expect(updatedConfig!.verifiedLanguages, contains('ar'));
      expect(updatedConfig.availableOptionalFeatures, isEmpty);
    });

    test('fully verified system is approved and updates configuration', () {
      final result = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(),
        verificationResult: MockJ095VerificationResult(),
        languageEvidence: [MockLanguageReadinessEvidence(languageCode: 'en')],
        optionalFeatures: [MockOptionalFeatureEvidence(featureName: 'tts', isAvailable: true)],
      );

      expect(result, PromotionEligibility.approved);

      final config = ProductionAcceptanceGate.lastApprovedConfiguration;
      expect(config, isNotNull);
      expect(config!.verifiedLanguages, contains('en'));
      expect(config.availableOptionalFeatures, contains('tts'));
    });

    test('blocked evaluations do not overwrite last approved configuration', () {
      // First establish an approved configuration
      ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(),
        verificationResult: MockJ095VerificationResult(),
        languageEvidence: [MockLanguageReadinessEvidence(languageCode: 'de')],
      );

      final configBefore = ProductionAcceptanceGate.lastApprovedConfiguration;
      expect(configBefore, isNotNull);
      expect(configBefore!.verifiedLanguages, contains('de'));

      // Now trigger a blocked evaluation
      final result = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: MockJ025StartupContract(hasNewDartErrors: true),
        verificationResult: MockJ095VerificationResult(),
      );

      expect(result, PromotionEligibility.blocked);

      // Verify the configuration is unchanged
      final configAfter = ProductionAcceptanceGate.lastApprovedConfiguration;
      expect(configAfter, isNotNull);
      expect(configAfter!.verifiedLanguages, contains('de'));
    });
  });
}
