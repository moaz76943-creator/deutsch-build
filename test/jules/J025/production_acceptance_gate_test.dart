import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

class TestVerificationContract implements J095VerificationContract {
  @override
  bool hasMandatoryEvidence = true;
  @override
  bool hasStaleEvidence = false;
  @override
  bool hasNewDartErrors = false;
  @override
  bool hasMemoryRegression = false;
  @override
  bool hasFTS5Regression = false;
  @override
  bool hasCorruptStorage = false;
  @override
  bool isNormalStartupVerified = true;
  @override
  bool isSafeModeBehaviorVerified = true;
}

class TestLanguageContract implements J025LanguageContract {
  @override
  bool hasLocalPackEvidence = true;
  @override
  bool isMetadataOnly = false;
}

class TestOptionalFeatureContract implements OptionalFeatureContract {
  @override
  bool isTtsAvailable = true;
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

    test('evaluate - Successful pass', () {
      final contract = TestVerificationContract();
      final lang = TestLanguageContract();
      final optionalFeatures = TestOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: optionalFeatures,
      );

      expect(result.outcome, GateOutcome.passed);
      expect(result.isDegraded, isFalse);
    });

    test('evaluate - Missing integrity evidence blocks acceptance', () {
      final contract = TestVerificationContract();
      final lang = TestLanguageContract()..hasLocalPackEvidence = false;
      final optionalFeatures = TestOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: optionalFeatures,
      );
      expect(result.outcome, GateOutcome.blocked);
    });

    test('evaluate - Corrupted content fails acceptance', () {
      final contract = TestVerificationContract()..hasCorruptStorage = true;
      final lang = TestLanguageContract();
      final optionalFeatures = TestOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: optionalFeatures,
      );
      expect(result.outcome, GateOutcome.failed);
    });

    test('evaluate - Failed startup recovery fails acceptance', () {
      final contract = TestVerificationContract()..isNormalStartupVerified = false;
      final lang = TestLanguageContract();
      final optionalFeatures = TestOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: optionalFeatures,
      );
      expect(result.outcome, GateOutcome.failed);
    });

    test('evaluate - Missing infrastructure blocks acceptance', () {
      final contract = TestVerificationContract();
      final lang = TestLanguageContract();
      final optionalFeatures = TestOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: false,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: optionalFeatures,
      );
      expect(result.outcome, GateOutcome.blocked);
    });

    test('evaluate - Stale verification marks as not run', () {
      final contract = TestVerificationContract()..hasStaleEvidence = true;
      final lang = TestLanguageContract();
      final optionalFeatures = TestOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: optionalFeatures,
      );
      expect(result.outcome, GateOutcome.notRun);
    });

    test('evaluate - Unsupported language claims block acceptance', () {
      final contract = TestVerificationContract();
      final lang = TestLanguageContract()..isMetadataOnly = true;
      final optionalFeatures = TestOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: optionalFeatures,
      );
      expect(result.outcome, GateOutcome.blocked);
    });

    test('evaluate - Missing optional audio results in degraded but passed acceptance', () {
      final contract = TestVerificationContract();
      final lang = TestLanguageContract();
      final optionalFeatures = TestOptionalFeatureContract()..isTtsAvailable = false;

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: optionalFeatures,
      );
      expect(result.outcome, GateOutcome.passed);
      expect(result.isDegraded, isTrue);
    });
  });
}
