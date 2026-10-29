import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

void main() {
  group('ProductionAcceptanceGate - evaluateReadiness (Positive Tests)', () {
    test('passes when all mandatory evidence is present and valid', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        verificationTimestamp: DateTime.now(),
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);

      expect(result.outcome, GateOutcome.PASSED);
      expect(result.verifiedLanguages, isEmpty);
      expect(result.isAudioAvailable, isFalse);
    });

    test('passes and verifies declared production-ready languages', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        verificationTimestamp: DateTime.now(),
        declaredLanguages: ['de', 'ar', 'en'], // Production-ready in LanguageReadinessMatrix
        isAudioAvailable: true,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);

      expect(result.outcome, GateOutcome.PASSED);
      expect(result.verifiedLanguages, containsAll(['de', 'ar', 'en']));
      expect(result.isAudioAvailable, isTrue);
    });
  });

  group('ProductionAcceptanceGate - verifyAppReadiness (Legacy Adapter)', () {
    test('returns true for complete legacy evidence', () {
      final isReady = ProductionAcceptanceGate.verifyAppReadiness(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      expect(isReady, isTrue);
    });

    test('returns false if any legacy evidence is missing', () {
      expect(
        ProductionAcceptanceGate.verifyAppReadiness(
          isOfflineSafe: false,
          isStorageGuarded: true,
          isLifecycleManaged: true,
        ),
        isFalse,
      );
    });
  });

  group('ProductionAcceptanceGate - evaluateReadiness (Negative Tests)', () {
    test('returns NOT_RUN if verificationTimestamp is null', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        verificationTimestamp: null,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);

      expect(result.outcome, GateOutcome.NOT_RUN);
    });

    test('returns BLOCKED if storage corruption is detected', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        verificationTimestamp: DateTime.now(),
        hasStorageCorruption: true,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);

      expect(result.outcome, GateOutcome.BLOCKED);
      expect(result.reason, contains('Storage corruption'));
    });

    test('returns BLOCKED if startup recovery failed', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        verificationTimestamp: DateTime.now(),
        hasStartupRecoveryFailed: true,
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);

      expect(result.outcome, GateOutcome.BLOCKED);
      expect(result.reason, contains('Startup recovery failed'));
    });

    test('returns FAILED if offline safety is missing', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: false,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        verificationTimestamp: DateTime.now(),
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);

      expect(result.outcome, GateOutcome.FAILED);
    });

    test('returns FAILED if verification results are stale (older than 1 hour)', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        verificationTimestamp: DateTime.now().subtract(const Duration(hours: 2)),
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);

      expect(result.outcome, GateOutcome.FAILED);
      expect(result.reason, contains('Stale verification results'));
    });

    test('returns FAILED for unverified dictionary claim', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        verificationTimestamp: DateTime.now(),
        declaredLanguages: ['fr'], // 'fr' is not productionReady (only assetsReady)
      );
      final result = ProductionAcceptanceGate.evaluateReadiness(evidence);

      expect(result.outcome, GateOutcome.FAILED);
      expect(result.reason, contains('Unverified dictionary claim'));
    });
  });
}
