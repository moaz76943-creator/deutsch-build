import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

void main() {
  group('ProductionAcceptanceGate', () {
    test('Perfect evidence yields PASSED/APPROVED', () {
      final evidence = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        registeredLanguages: {'en', 'de'}, verifiedDictionaries: {'en', 'de'},
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);
      expect(result.outcome, GateOutcome.passed);
      expect(result.eligibility, PromotionEligibility.approved);
      expect(result.isReady, isTrue);
    });

    test('Missing optional features yields PASSED/DEGRADED', () {
      final evidence = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasOptionalAudio: false,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);
      expect(result.outcome, GateOutcome.passed);
      expect(result.eligibility, PromotionEligibility.degraded);
      expect(result.isReady, isTrue);
    });

    test('Missing evidence (null) yields NOT_RUN/NOT_VERIFIED', () {
      final result = ProductionAcceptanceGate.evaluateReadiness(null);
      expect(result.outcome, GateOutcome.notRun);
      expect(result.eligibility, PromotionEligibility.notVerified);
      expect(result.isReady, isFalse);
    });

    test('Stale evidence yields NOT_RUN/NOT_VERIFIED', () {
      final evidence = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        isVerificationStale: true,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);
      expect(result.outcome, GateOutcome.notRun);
      expect(result.eligibility, PromotionEligibility.notVerified);
      expect(result.isReady, isFalse);
    });

    test('Corrupted content yields BLOCKED/BLOCKED', () {
      final evidence = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        isContentCorrupted: true,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);
      expect(result.outcome, GateOutcome.blocked);
      expect(result.eligibility, PromotionEligibility.blocked);
      expect(result.isReady, isFalse);
    });

    test('Regressions yield BLOCKED/BLOCKED', () {
      final evidence = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        isStartupRecoveryFailed: true,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);
      expect(result.outcome, GateOutcome.blocked);
      expect(result.eligibility, PromotionEligibility.blocked);
      expect(result.isReady, isFalse);
    });

    test('Missing mandatory infrastructure yields FAILED/BLOCKED', () {
      final evidence = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: false,
        isLifecycleManaged: true,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);
      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
      expect(result.isReady, isFalse);
    });

    test('Unsupported language claims yields FAILED/BLOCKED', () {
      final evidence = J025StartupContract(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        registeredLanguages: {'fr'}, verifiedDictionaries: {}, // 'fr' is assetsReady, not productionReady
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);
      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
      expect(result.isReady, isFalse);
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
