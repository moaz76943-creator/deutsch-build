import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/quality/production_acceptance_gate.dart';

class MockJ095VerificationContract implements J095VerificationContract {
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

class MockJ025LanguageContract implements J025LanguageContract {
  @override
  String languageCode = 'en';
  @override
  bool hasLocalPackEvidence = true;
  @override
  bool isMetadataOnly = false;
}

class MockOptionalFeatureContract implements OptionalFeatureContract {
  @override
  bool isTtsAvailable = true;
}

void main() {
  group('ProductionAcceptanceGate', () {
    test('passes when all evidence is present and valid', () {
      final contract = MockJ095VerificationContract();
      final lang = MockJ025LanguageContract();
      final features = MockOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: features,
      );

      expect(result.outcome, GateOutcome.passed);
      expect(result.isDegraded, false);
      expect(ProductionAcceptanceGate.lastApprovedConfiguration, isNotNull);
      expect(ProductionAcceptanceGate.lastApprovedConfiguration?.verifiedLanguages, contains('en'));
      expect(ProductionAcceptanceGate.lastApprovedConfiguration?.availableOptionalFeatures, contains('tts'));
    });

    test('is degraded when TTS is not available', () {
      final contract = MockJ095VerificationContract();
      final lang = MockJ025LanguageContract();
      final features = MockOptionalFeatureContract()..isTtsAvailable = false;

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: features,
      );

      expect(result.outcome, GateOutcome.passed);
      expect(result.isDegraded, true);
    });

    test('is notRun when verification contract is missing', () {
      final lang = MockJ025LanguageContract();
      final features = MockOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: null,
        languages: [lang],
        optionalFeatures: features,
      );

      expect(result.outcome, GateOutcome.notRun);
    });

    test('is notRun when mandatory evidence is missing', () {
      final contract = MockJ095VerificationContract()..hasMandatoryEvidence = false;
      final lang = MockJ025LanguageContract();
      final features = MockOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: features,
      );

      expect(result.outcome, GateOutcome.notRun);
    });

    test('is notRun when evidence is stale', () {
      final contract = MockJ095VerificationContract()..hasStaleEvidence = true;
      final lang = MockJ025LanguageContract();
      final features = MockOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: features,
      );

      expect(result.outcome, GateOutcome.notRun);
    });

    test('is blocked when app readiness checks fail', () {
      final contract = MockJ095VerificationContract();
      final lang = MockJ025LanguageContract();
      final features = MockOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: false, // failing check
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: features,
      );

      expect(result.outcome, GateOutcome.blocked);
    });

    test('is failed when storage is corrupt', () {
      final contract = MockJ095VerificationContract()..hasCorruptStorage = true;
      final lang = MockJ025LanguageContract();
      final features = MockOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: features,
      );

      expect(result.outcome, GateOutcome.failed);
    });

    test('is failed when startup recovery failed', () {
      final contract = MockJ095VerificationContract()..isNormalStartupVerified = false;
      final lang = MockJ025LanguageContract();
      final features = MockOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: features,
      );

      expect(result.outcome, GateOutcome.failed);
    });

    test('is failed when regression detected', () {
      final contract = MockJ095VerificationContract()..hasFTS5Regression = true;
      final lang = MockJ025LanguageContract();
      final features = MockOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: features,
      );

      expect(result.outcome, GateOutcome.failed);
    });

    test('is blocked when local pack evidence is missing', () {
      final contract = MockJ095VerificationContract();
      final lang = MockJ025LanguageContract()..hasLocalPackEvidence = false;
      final features = MockOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: features,
      );

      expect(result.outcome, GateOutcome.blocked);
    });

    test('is blocked when language is metadata only', () {
      final contract = MockJ095VerificationContract();
      final lang = MockJ025LanguageContract()..isMetadataOnly = true;
      final features = MockOptionalFeatureContract();

      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [lang],
        optionalFeatures: features,
      );

      expect(result.outcome, GateOutcome.blocked);
    });
  });
}
