import 'package:flutter_test/flutter_test.dart';

// ignore: avoid_relative_lib_imports
import '../../../lib/core/quality/production_acceptance_gate.dart';

class MockJ025StartupContract implements J025StartupContract {
  @override
  bool isOfflineSafe;

  @override
  bool isStorageGuarded;

  @override
  bool isLifecycleManaged;

  @override
  bool isContentCorrupted;

  @override
  bool isIntegrityEvidenceMissing;

  @override
  bool isStartupRecoveryFailed;

  @override
  bool isVerificationStale;

  @override
  Set<String> registeredLanguages;

  @override
  Set<String> verifiedDictionaries;

  @override
  bool hasOptionalAudio;

  @override
  bool hasExecutedTests;

  MockJ025StartupContract({
    this.isOfflineSafe = true,
    this.isStorageGuarded = true,
    this.isLifecycleManaged = true,
    this.isContentCorrupted = false,
    this.isIntegrityEvidenceMissing = false,
    this.isStartupRecoveryFailed = false,
    this.isVerificationStale = false,
    this.registeredLanguages = const {'en'},
    this.verifiedDictionaries = const {'en'},
    this.hasOptionalAudio = true,
    this.hasExecutedTests = true,
  });

  @override
  bool get hasNewDartErrors => false;

  @override
  bool get hasNormalStartup => !isStartupRecoveryFailed;

  @override
  bool get hasSafeModeStartup => true;
}

void main() {
  group('ProductionAcceptanceGate evaluateReadiness Tests', () {
    test('passes with all correct evidence', () {
      final contract = MockJ025StartupContract();
      final gate = ProductionAcceptanceGate();

      final result = gate.evaluateReadiness(contract);

      expect(result.outcome, GateOutcome.passed);
      expect(result.eligibility, PromotionEligibility.approved);
    });

    test('blocks on missing tests executed', () {
      final contract = MockJ025StartupContract(hasExecutedTests: false);
      final gate = ProductionAcceptanceGate();

      final result = gate.evaluateReadiness(contract);

      expect(result.outcome, GateOutcome.notRun);
      expect(result.eligibility, PromotionEligibility.notVerified);
    });

    test('blocks on stale verification results', () {
      final contract = MockJ025StartupContract(isVerificationStale: true);
      final gate = ProductionAcceptanceGate();

      final result = gate.evaluateReadiness(contract);

      expect(result.outcome, GateOutcome.notRun);
      expect(result.eligibility, PromotionEligibility.notVerified);
    });

    test('blocks on corrupt content', () {
      final contract = MockJ025StartupContract(isContentCorrupted: true);
      final gate = ProductionAcceptanceGate();

      final result = gate.evaluateReadiness(contract);

      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
    });

    test('blocks on failed startup recovery', () {
      final contract = MockJ025StartupContract(isStartupRecoveryFailed: true);
      final gate = ProductionAcceptanceGate();

      final result = gate.evaluateReadiness(contract);

      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
    });

    test('blocks on failed infrastructure checks', () {
      final contract = MockJ025StartupContract(isOfflineSafe: false);
      final gate = ProductionAcceptanceGate();

      final result = gate.evaluateReadiness(contract);

      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
    });

    test('degrades gracefully with missing optional audio', () {
      final contract = MockJ025StartupContract(hasOptionalAudio: false);
      final gate = ProductionAcceptanceGate();

      final result = gate.evaluateReadiness(contract);

      expect(result.outcome, GateOutcome.passed);
      expect(result.eligibility, PromotionEligibility.degraded);
    });

    test('blocks on unsupported language claims', () {
      final contract = MockJ025StartupContract(
          registeredLanguages: {'en', 'es'}, verifiedDictionaries: {'en'});
      final gate = ProductionAcceptanceGate();

      final result = gate.evaluateReadiness(contract);

      expect(result.outcome, GateOutcome.failed);
      expect(result.eligibility, PromotionEligibility.blocked);
    });

    test('blocks on missing integrity evidence', () {
      final contract = MockJ025StartupContract(isIntegrityEvidenceMissing: true);
      final gate = ProductionAcceptanceGate();

      final result = gate.evaluateReadiness(contract);

      expect(result.outcome, GateOutcome.blocked);
      expect(result.eligibility, PromotionEligibility.blocked);
    });
  });
}
