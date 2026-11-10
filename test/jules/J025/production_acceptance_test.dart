import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

void main() {
  group('ProductionAcceptanceGate', () {
    test('evaluateReadiness passes full contract', () {
      final contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.passed);
      expect(result.eligibility, PromotionEligibility.approved);
      expect(ProductionAcceptanceGate.lastApprovedConfiguration?.availableOptionalFeatures, contains('audio'));
    });

    test('evaluateReadiness passes with degraded audio', () {
      final contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasOptionalAudio: false,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.passed);
      expect(result.eligibility, PromotionEligibility.degraded);
      expect(ProductionAcceptanceGate.lastApprovedConfiguration?.availableOptionalFeatures, isEmpty);
    });

    test('evaluateReadiness fails on missing mandatory infrastructure', () {
      final missingOfflineSafe = J025StartupContract(
        isOfflineSafe: false,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      final r1 = ProductionAcceptanceGate.evaluateReadiness(missingOfflineSafe);
      expect(r1.outcome, GateOutcome.failed);
      expect(r1.eligibility, PromotionEligibility.blocked);

      final missingStorageGuarded = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: false,
        isLifecycleManaged: true,
      );
      final r2 = ProductionAcceptanceGate.evaluateReadiness(missingStorageGuarded);
      expect(r2.outcome, GateOutcome.failed);
      expect(r2.eligibility, PromotionEligibility.blocked);

      final missingLifecycleManaged = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: false,
      );
      final r3 = ProductionAcceptanceGate.evaluateReadiness(missingLifecycleManaged);
      expect(r3.outcome, GateOutcome.failed);
      expect(r3.eligibility, PromotionEligibility.blocked);
    });

    test('evaluateReadiness fails on corrupted content', () {
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

    test('evaluateReadiness fails on failed startup recovery', () {
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

    test('evaluateReadiness blocks on missing integrity evidence', () {
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

    test('evaluateReadiness flags stale verification as not run', () {
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

    test('evaluateReadiness flags missing executed tests as not run', () {
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

    test('evaluateReadiness fails on unsupported language claims', () {
      final contract = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        registeredLanguages: {'de', 'ar', 'en'},
        verifiedDictionaries: {'de', 'ar'}, // Missing 'en'
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(contract);
      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
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
