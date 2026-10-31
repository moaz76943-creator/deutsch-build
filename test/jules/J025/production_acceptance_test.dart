import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

void main() {
  group('ProductionAcceptanceGate', () {
    test('Perfect evidence yields PASSED/APPROVED', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        verifiedLanguages: ['en', 'de'],
      );
      final result = ProductionAcceptanceGate.evaluateEvidence(evidence);
      expect(result.outcome, GateOutcome.passed);
      expect(result.state, EligibilityState.approved);
      expect(result.isReady, isTrue);
    });

    test('Missing optional features yields PASSED/DEGRADED', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        missingOptionalFeatures: true,
      );
      final result = ProductionAcceptanceGate.evaluateEvidence(evidence);
      expect(result.outcome, GateOutcome.passed);
      expect(result.state, EligibilityState.degraded);
      expect(result.isReady, isTrue);
    });

    test('Missing evidence (null) yields NOT_RUN/NOT_VERIFIED', () {
      final result = ProductionAcceptanceGate.evaluateEvidence(null);
      expect(result.outcome, GateOutcome.notRun);
      expect(result.state, EligibilityState.notVerified);
      expect(result.isReady, isFalse);
    });

    test('Stale evidence yields NOT_RUN/NOT_VERIFIED', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        isStale: true,
      );
      final result = ProductionAcceptanceGate.evaluateEvidence(evidence);
      expect(result.outcome, GateOutcome.notRun);
      expect(result.state, EligibilityState.notVerified);
      expect(result.isReady, isFalse);
    });

    test('Corrupted content yields BLOCKED/BLOCKED', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasCorruptedContent: true,
      );
      final result = ProductionAcceptanceGate.evaluateEvidence(evidence);
      expect(result.outcome, GateOutcome.blocked);
      expect(result.state, EligibilityState.blocked);
      expect(result.isReady, isFalse);
    });

    test('Regressions yield BLOCKED/BLOCKED', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasRegressions: true,
      );
      final result = ProductionAcceptanceGate.evaluateEvidence(evidence);
      expect(result.outcome, GateOutcome.blocked);
      expect(result.state, EligibilityState.blocked);
      expect(result.isReady, isFalse);
    });

    test('Missing mandatory infrastructure yields FAILED/BLOCKED', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: false,
        isLifecycleManaged: true,
      );
      final result = ProductionAcceptanceGate.evaluateEvidence(evidence);
      expect(result.outcome, GateOutcome.failed);
      expect(result.state, EligibilityState.blocked);
      expect(result.isReady, isFalse);
    });

    test('Unsupported language claims yields FAILED/BLOCKED', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        verifiedLanguages: ['fr'], // 'fr' is assetsReady, not productionReady
      );
      final result = ProductionAcceptanceGate.evaluateEvidence(evidence);
      expect(result.outcome, GateOutcome.failed);
      expect(result.state, EligibilityState.blocked);
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
