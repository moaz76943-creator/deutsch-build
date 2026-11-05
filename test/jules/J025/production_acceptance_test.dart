import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

class MockLanguageReadinessEvidence implements LanguageReadinessEvidence {
  @override
  final String languageCode;
  @override
  final bool hasLocalPackEvidence;
  @override
  final bool isMetadataOnly;

  MockLanguageReadinessEvidence(
    this.languageCode, {
    this.hasLocalPackEvidence = true,
    this.isMetadataOnly = false,
  });
}

class MockOptionalFeatureEvidence implements OptionalFeatureEvidence {
  @override
  final String featureName;
  @override
  final bool isAvailable;

  MockOptionalFeatureEvidence(
    this.featureName, {
    this.isAvailable = true,
  });
}

void main() {
  group('ProductionAcceptanceGate', () {
    test('Perfect evidence yields APPROVED', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      final promotion = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: contract,
        verificationResult: result,
        languageEvidence: [
          MockLanguageReadinessEvidence('en'),
          MockLanguageReadinessEvidence('de'),
        ],
        optionalFeatures: [
          MockOptionalFeatureEvidence('audio', isAvailable: true),
        ],
      );
      expect(promotion, PromotionEligibility.approved);
    });

    test('Missing optional features yields DEGRADED', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      final promotion = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: contract,
        verificationResult: result,
        languageEvidence: [
          MockLanguageReadinessEvidence('en'),
        ],
        optionalFeatures: [
          MockOptionalFeatureEvidence('audio', isAvailable: false),
        ],
      );
      expect(promotion, PromotionEligibility.degraded);
    });

    test('Missing evidence (null) yields NOT_VERIFIED', () {
      final promotion = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: null,
        verificationResult: null,
      );
      expect(promotion, PromotionEligibility.notVerified);
    });

    test('Stale evidence yields NOT_VERIFIED', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      const result = J095VerificationResult(
        outcome: GateOutcome.notRun,
        eligibility: PromotionEligibility.notVerified,
        reason: 'Stale evidence',
        isEvidenceStale: true,
      );
      final promotion = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: contract,
        verificationResult: result,
      );
      expect(promotion, PromotionEligibility.notVerified);
    });

    test('Corrupted content yields BLOCKED', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      const result = J095VerificationResult(
        outcome: GateOutcome.failed,
        eligibility: PromotionEligibility.blocked,
        reason: 'Corrupted content',
        isStorageCorrupt: true,
      );
      final promotion = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: contract,
        verificationResult: result,
      );
      expect(promotion, PromotionEligibility.blocked);
    });

    test('Regressions yield BLOCKED', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      const result = J095VerificationResult(
        outcome: GateOutcome.failed,
        eligibility: PromotionEligibility.blocked,
        reason: 'Regression',
        hasMemoryRegression: true,
      );
      final promotion = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: contract,
        verificationResult: result,
      );
      expect(promotion, PromotionEligibility.blocked);
    });

    test('Missing mandatory infrastructure yields NOT_VERIFIED', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      const result = J095VerificationResult(
        outcome: GateOutcome.failed,
        eligibility: PromotionEligibility.blocked,
        reason: 'Missing mandatory evidence',
        hasMissingMandatoryEvidence: true,
      );
      final promotion = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: contract,
        verificationResult: result,
      );
      expect(promotion, PromotionEligibility.notVerified);
    });

    test('Unsupported language claims yields BLOCKED', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      final promotion = ProductionAcceptanceGate.evaluatePromotion(
        startupContract: contract,
        verificationResult: result,
        languageEvidence: [
          MockLanguageReadinessEvidence('fr', isMetadataOnly: true), // Metadata only
        ],
      );
      expect(promotion, PromotionEligibility.blocked);
    });

    test('Legacy verifyAppReadiness acts as adapter', () {
      final passed = ProductionAcceptanceGate.verifyAppReadiness(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      expect(passed, isTrue);

      final failed = ProductionAcceptanceGate.verifyAppReadiness(
        isOfflineSafe: true,
        isStorageGuarded: false,
        isLifecycleManaged: true,
      );
      expect(failed, isFalse);
    });
  });
}
