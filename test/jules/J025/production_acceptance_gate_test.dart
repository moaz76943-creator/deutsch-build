import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

class _MockLanguageReadinessEvidence implements LanguageReadinessEvidence {
  @override
  final String languageCode;
  @override
  final bool hasLocalPackEvidence;
  @override
  final bool isMetadataOnly;

  const _MockLanguageReadinessEvidence({
    required this.languageCode,
    this.hasLocalPackEvidence = true,
    this.isMetadataOnly = false,
  });
}

void main() {
  group('ProductionAcceptanceGate', () {
    test('verifyAppReadiness remains backward compatible', () {
      expect(
        ProductionAcceptanceGate.verifyAppReadiness(
          isOfflineSafe: true,
          isStorageGuarded: true,
          isLifecycleManaged: true,
        ),
        isTrue,
      );

      expect(
        ProductionAcceptanceGate.verifyAppReadiness(
          isOfflineSafe: false,
          isStorageGuarded: true,
          isLifecycleManaged: true,
        ),
        isFalse,
      );
    });

    test('Missing integrity evidence blocks acceptance', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        isIntegrityEvidenceMissing: true,
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.blocked);
      expect(result.eligibility, PromotionEligibility.blocked);
    });

    test('Corrupted content fails acceptance', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        isContentCorrupted: true,
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
    });

    test('Failed startup recovery fails acceptance', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        isStartupRecoveryFailed: true,
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
    });

    test('Missing infrastructure fails acceptance', () {
      const contract = J025StartupContract(
        isOfflineSafe: false,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
    });

    test('Unexecuted tests mark as not run', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasExecutedTests: false,
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.notRun);
      expect(result.eligibility, PromotionEligibility.notVerified);
    });

    test('Stale verification marks as not run', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        isVerificationStale: true,
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.notRun);
      expect(result.eligibility, PromotionEligibility.notVerified);
    });

    test('Unsupported language claims fail acceptance', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        registeredLanguages: {'en', 'de', 'fr'},
        verifiedDictionaries: {'en', 'de'},
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
    });

    test('Missing optional audio results in degraded but passed acceptance', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasOptionalAudio: false,
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.passed);
      expect(result.eligibility, PromotionEligibility.degraded);
    });

    test('Missing local pack evidence blocks acceptance', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        languageEvidence: [
          _MockLanguageReadinessEvidence(languageCode: 'en', hasLocalPackEvidence: false),
        ],
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
      expect(result.reason, 'Missing local pack evidence for language.');
    });

    test('Metadata-only languages block acceptance', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        languageEvidence: [
          _MockLanguageReadinessEvidence(languageCode: 'en', isMetadataOnly: true),
        ],
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
      expect(result.reason, 'Metadata-only languages cannot be certified as ready.');
    });

    test('Successful pass', () {
      const contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.passed);
      expect(result.eligibility, PromotionEligibility.approved);
    });
  });
}
