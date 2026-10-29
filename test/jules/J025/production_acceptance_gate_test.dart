import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

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
      final contract = J025StartupContract(
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
      final contract = J025StartupContract(
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
      final contract = J025StartupContract(
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
      final contract = J025StartupContract(
        isOfflineSafe: false,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
    });

    test('Unexecuted tests mark as not run', () {
      final contract = J025StartupContract(
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
      final contract = J025StartupContract(
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
      final contract = J025StartupContract(
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
      final contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasOptionalAudio: false,
      );

      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.passed);
      expect(result.eligibility, PromotionEligibility.degraded);
    });

    test('Successful pass', () {
      final contract = J025StartupContract(
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
