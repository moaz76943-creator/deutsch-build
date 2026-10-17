import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

void main() {
  group('ProductionAcceptanceGate Tests', () {
    test('missing verificationTime returns notRun/notVerified', () {
      final evidence = AcceptanceEvidence();
      final result = ProductionAcceptanceGate.evaluate(evidence);
      expect(result.outcome, GateOutcome.notRun);
      expect(result.state, EligibilityState.notVerified);
    });

    test('stale verificationTime returns failed/blocked', () {
      final now = DateTime.now();
      final evidence = AcceptanceEvidence(
        verificationTime: now.subtract(const Duration(minutes: 31)),
      );
      final result = ProductionAcceptanceGate.evaluate(evidence, now: now);
      expect(result.outcome, GateOutcome.failed);
      expect(result.state, EligibilityState.blocked);
    });

    test('future verificationTime returns failed/blocked', () {
      final now = DateTime.now();
      final evidence = AcceptanceEvidence(
        verificationTime: now.add(const Duration(minutes: 5)),
      );
      final result = ProductionAcceptanceGate.evaluate(evidence, now: now);
      expect(result.outcome, GateOutcome.failed);
      expect(result.state, EligibilityState.blocked);
    });

    test('missing mandatory evidence returns failed/blocked', () {
      final now = DateTime.now();
      final evidence = AcceptanceEvidence(
        verificationTime: now,
        isOfflineSafe: true,
        // isStorageGuarded missing
        isLifecycleManaged: true,
        isDatabaseIntact: true,
        isContentReady: true,
      );
      final result = ProductionAcceptanceGate.evaluate(evidence, now: now);
      expect(result.outcome, GateOutcome.failed);
      expect(result.state, EligibilityState.blocked);
    });

    test('false mandatory evidence returns blocked/blocked', () {
      final now = DateTime.now();
      final evidence = AcceptanceEvidence(
        verificationTime: now,
        isOfflineSafe: true,
        isStorageGuarded: false, // Explicit failure
        isLifecycleManaged: true,
        isDatabaseIntact: true,
        isContentReady: true,
      );
      final result = ProductionAcceptanceGate.evaluate(evidence, now: now);
      expect(result.outcome, GateOutcome.blocked);
      expect(result.state, EligibilityState.blocked);
    });

    test('fully verified evidence returns passed/approved', () {
      final now = DateTime.now();
      final evidence = AcceptanceEvidence(
        verificationTime: now,
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        isDatabaseIntact: true,
        isContentReady: true,
        optionalAudioAvailable: true,
        claimedLanguages: ['de', 'ar'],
      );
      final result = ProductionAcceptanceGate.evaluate(evidence, now: now);
      expect(result.outcome, GateOutcome.passed);
      expect(result.state, EligibilityState.approved);
      expect(result.readyLanguages, containsAll(['de', 'ar']));
    });

    test('fully verified evidence without audio returns passed/degraded', () {
      final now = DateTime.now();
      final evidence = AcceptanceEvidence(
        verificationTime: now,
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        isDatabaseIntact: true,
        isContentReady: true,
        optionalAudioAvailable: false, // Missing audio
        claimedLanguages: ['de'],
      );
      final result = ProductionAcceptanceGate.evaluate(evidence, now: now);
      expect(result.outcome, GateOutcome.passed);
      expect(result.state, EligibilityState.degraded);
      expect(result.readyLanguages, ['de']);
    });

    test('claimed languages not production ready are filtered out', () {
      final now = DateTime.now();
      final evidence = AcceptanceEvidence(
        verificationTime: now,
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        isDatabaseIntact: true,
        isContentReady: true,
        optionalAudioAvailable: true,
        claimedLanguages: ['de', 'fr', 'es', 'ar'],
      );
      final result = ProductionAcceptanceGate.evaluate(evidence, now: now);
      expect(result.outcome, GateOutcome.passed);
      expect(result.state, EligibilityState.approved);
      // 'de' and 'ar' are production ready. 'fr' and 'es' are assetsReady/nominal.
      expect(result.readyLanguages, ['de', 'ar']);
    });

    test('verifyAppReadiness fallback logic', () {
      final result1 = ProductionAcceptanceGate.verifyAppReadiness(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      expect(result1, isTrue);

      final result2 = ProductionAcceptanceGate.verifyAppReadiness(
        isOfflineSafe: true,
        isStorageGuarded: false,
        isLifecycleManaged: true,
      );
      expect(result2, isFalse);
    });
  });
}
