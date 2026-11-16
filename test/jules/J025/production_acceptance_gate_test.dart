import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

void main() {
  group('ProductionAcceptanceGate', () {
    group('Compatibility Adapter (verifyAppReadiness)', () {
      test('Returns true when all mandatory evidence is present', () {
        final ready = ProductionAcceptanceGate.verifyAppReadiness(
          isOfflineSafe: true,
          isStorageGuarded: true,
          isLifecycleManaged: true,
        );
        expect(ready, isTrue);
      });

      test('Returns false when missing mandatory evidence', () {
        final notReady = ProductionAcceptanceGate.verifyAppReadiness(
          isOfflineSafe: true,
          isStorageGuarded: false,
          isLifecycleManaged: true,
        );
        expect(notReady, isFalse);
      });
    });

    group('Executable Validation Authority (evaluateReadiness)', () {
      test('Missing tests produce NOT_RUN status', () {
        const contract = J025StartupContract(
          isOfflineSafe: true,
          isStorageGuarded: true,
          isLifecycleManaged: true,
          hasExecutedTests: false,
        );
        final result = ProductionAcceptanceGate.evaluateReadiness(contract);
        expect(result.outcome, GateOutcome.notRun);
        expect(result.eligibility, PromotionEligibility.notVerified);
        expect(result.reason, 'Verification tests have not executed.');
      });

      test('Stale verification produces NOT_RUN status', () {
        const contract = J025StartupContract(
          isOfflineSafe: true,
          isStorageGuarded: true,
          isLifecycleManaged: true,
          isVerificationStale: true,
        );
        final result = ProductionAcceptanceGate.evaluateReadiness(contract);
        expect(result.outcome, GateOutcome.notRun);
        expect(result.eligibility, PromotionEligibility.notVerified);
        expect(result.reason, 'Verification results are stale.');
      });

      test('Missing integrity evidence produces BLOCKED status', () {
        const contract = J025StartupContract(
          isOfflineSafe: true,
          isStorageGuarded: true,
          isLifecycleManaged: true,
          isIntegrityEvidenceMissing: true,
        );
        final result = ProductionAcceptanceGate.evaluateReadiness(contract);
        expect(result.outcome, GateOutcome.blocked);
        expect(result.eligibility, PromotionEligibility.blocked);
        expect(result.reason, 'Missing integrity evidence.');
      });

      test('Corrupted content produces FAILED status', () {
        const contract = J025StartupContract(
          isOfflineSafe: true,
          isStorageGuarded: true,
          isLifecycleManaged: true,
          isContentCorrupted: true,
        );
        final result = ProductionAcceptanceGate.evaluateReadiness(contract);
        expect(result.outcome, GateOutcome.failed);
        expect(result.eligibility, PromotionEligibility.blocked);
        expect(result.reason, 'Corrupted content detected.');
      });

      test('Failed startup recovery produces FAILED status', () {
        const contract = J025StartupContract(
          isOfflineSafe: true,
          isStorageGuarded: true,
          isLifecycleManaged: true,
          isStartupRecoveryFailed: true,
        );
        final result = ProductionAcceptanceGate.evaluateReadiness(contract);
        expect(result.outcome, GateOutcome.failed);
        expect(result.eligibility, PromotionEligibility.blocked);
        expect(result.reason, 'Startup recovery failed.');
      });

      test('Missing offline safety evidence produces FAILED status', () {
        const contract = J025StartupContract(
          isOfflineSafe: false,
          isStorageGuarded: true,
          isLifecycleManaged: true,
        );
        final result = ProductionAcceptanceGate.evaluateReadiness(contract);
        expect(result.outcome, GateOutcome.failed);
        expect(result.eligibility, PromotionEligibility.blocked);
        expect(result.reason, 'Mandatory infrastructure checks failed.');
      });

      test('Missing storage guard evidence produces FAILED status', () {
        const contract = J025StartupContract(
          isOfflineSafe: true,
          isStorageGuarded: false,
          isLifecycleManaged: true,
        );
        final result = ProductionAcceptanceGate.evaluateReadiness(contract);
        expect(result.outcome, GateOutcome.failed);
        expect(result.eligibility, PromotionEligibility.blocked);
        expect(result.reason, 'Mandatory infrastructure checks failed.');
      });

      test('Missing lifecycle management evidence produces FAILED status', () {
        const contract = J025StartupContract(
          isOfflineSafe: true,
          isStorageGuarded: true,
          isLifecycleManaged: false,
        );
        final result = ProductionAcceptanceGate.evaluateReadiness(contract);
        expect(result.outcome, GateOutcome.failed);
        expect(result.eligibility, PromotionEligibility.blocked);
        expect(result.reason, 'Mandatory infrastructure checks failed.');
      });

      test('Unsupported language claims (metadata-only without verified dictionaries) produce FAILED status', () {
        const contract = J025StartupContract(
          isOfflineSafe: true,
          isStorageGuarded: true,
          isLifecycleManaged: true,
          registeredLanguages: {'de-AR', 'en-AR'},
          verifiedDictionaries: {'de-AR'}, // en-AR is missing
        );
        final result = ProductionAcceptanceGate.evaluateReadiness(contract);
        expect(result.outcome, GateOutcome.failed);
        expect(result.eligibility, PromotionEligibility.blocked);
        expect(result.reason, 'Unsupported language claims detected.');
      });

      test('Missing optional audio produces PASSED status but degraded eligibility', () {
        const contract = J025StartupContract(
          isOfflineSafe: true,
          isStorageGuarded: true,
          isLifecycleManaged: true,
          hasOptionalAudio: false,
        );
        final result = ProductionAcceptanceGate.evaluateReadiness(contract);
        expect(result.outcome, GateOutcome.passed);
        expect(result.eligibility, PromotionEligibility.degraded);
        expect(result.reason, 'Passed with degraded optional features.');
      });

      test('Successful acceptance with all required evidence produces PASSED and approved eligibility', () {
        const contract = J025StartupContract(
          isOfflineSafe: true,
          isStorageGuarded: true,
          isLifecycleManaged: true,
          registeredLanguages: {'de-AR'},
          verifiedDictionaries: {'de-AR'},
          hasOptionalAudio: true,
        );
        final result = ProductionAcceptanceGate.evaluateReadiness(contract);
        expect(result.outcome, GateOutcome.passed);
        expect(result.eligibility, PromotionEligibility.approved);
        expect(result.reason, 'All mandatory and optional checks passed.');
      });
    });
  });
}
