import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

void main() {
  group('ProductionAcceptanceGate Tests', () {
    test('missing mandatory evidence -> notVerified / failed', () {
      final evidence = AcceptanceEvidence(
        hasJ025Contract: false,
        hasJ095Contract: true,
        dartErrorsDetected: false,
        memoryRegressionConfirmed: false,
        fts5RegressionConfirmed: false,
        normalStartupVerified: true,
        safeModeVerified: true,
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        optionalTtsAvailable: true,
      );

      final result = ProductionAcceptanceGate.evaluate(evidence);
      expect(result.outcome, GateOutcome.failed);
      expect(result.state, EligibilityState.notVerified);
    });

    test('failed benchmarks (regressions) -> blocked', () {
      final evidence = AcceptanceEvidence(
        hasJ025Contract: true,
        hasJ095Contract: true,
        dartErrorsDetected: false,
        memoryRegressionConfirmed: true,
        fts5RegressionConfirmed: false,
        normalStartupVerified: true,
        safeModeVerified: true,
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        optionalTtsAvailable: true,
      );

      final result = ProductionAcceptanceGate.evaluate(evidence);
      expect(result.outcome, GateOutcome.blocked);
      expect(result.state, EligibilityState.blocked);
    });

    test('corrupt storage / critical failures -> failed', () {
      final evidence = AcceptanceEvidence(
        hasJ025Contract: true,
        hasJ095Contract: true,
        dartErrorsDetected: false,
        memoryRegressionConfirmed: false,
        fts5RegressionConfirmed: false,
        normalStartupVerified: true,
        safeModeVerified: true,
        isOfflineSafe: true,
        isStorageGuarded: false,
        isLifecycleManaged: true,
        optionalTtsAvailable: true,
      );

      final result = ProductionAcceptanceGate.evaluate(evidence);
      expect(result.outcome, GateOutcome.failed);
      expect(result.state, EligibilityState.notVerified);
    });

    test('optional TTS absence -> degraded', () {
      final evidence = AcceptanceEvidence(
        hasJ025Contract: true,
        hasJ095Contract: true,
        dartErrorsDetected: false,
        memoryRegressionConfirmed: false,
        fts5RegressionConfirmed: false,
        normalStartupVerified: true,
        safeModeVerified: true,
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        optionalTtsAvailable: false,
      );

      final result = ProductionAcceptanceGate.evaluate(evidence);
      expect(result.outcome, GateOutcome.passed);
      expect(result.state, EligibilityState.degraded);
    });

    test('stale evidence -> fail closed', () {
      final evidence = AcceptanceEvidence(
        hasJ025Contract: true,
        hasJ095Contract: true,
        dartErrorsDetected: false,
        memoryRegressionConfirmed: false,
        fts5RegressionConfirmed: false,
        normalStartupVerified: true,
        safeModeVerified: true,
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        optionalTtsAvailable: true,
        isStale: true,
      );

      final result = ProductionAcceptanceGate.evaluate(evidence);
      expect(result.outcome, GateOutcome.failed);
      expect(result.state, EligibilityState.notVerified);
    });

    test('existing public API verifyAppReadiness backward compatibility', () {
      final result = ProductionAcceptanceGate.verifyAppReadiness(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      expect(result, true);

      final resultFalse = ProductionAcceptanceGate.verifyAppReadiness(
        isOfflineSafe: true,
        isStorageGuarded: false,
        isLifecycleManaged: true,
      );
      expect(resultFalse, false);
    });

    test('language readiness matrix integration - production ready', () {
      final evidence = AcceptanceEvidence(
        hasJ025Contract: true,
        hasJ095Contract: true,
        dartErrorsDetected: false,
        memoryRegressionConfirmed: false,
        fts5RegressionConfirmed: false,
        normalStartupVerified: true,
        safeModeVerified: true,
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        optionalTtsAvailable: true,
        languageCode: 'en',
      );

      final result = ProductionAcceptanceGate.evaluate(evidence);
      expect(result.outcome, GateOutcome.passed);
      expect(result.state, EligibilityState.approved);
    });

    test('language readiness matrix integration - not production ready', () {
      final evidence = AcceptanceEvidence(
        hasJ025Contract: true,
        hasJ095Contract: true,
        dartErrorsDetected: false,
        memoryRegressionConfirmed: false,
        fts5RegressionConfirmed: false,
        normalStartupVerified: true,
        safeModeVerified: true,
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        optionalTtsAvailable: true,
        languageCode: 'fr',
      );

      final result = ProductionAcceptanceGate.evaluate(evidence);
      expect(result.outcome, GateOutcome.failed);
      expect(result.state, EligibilityState.notVerified);
    });
  });
}
