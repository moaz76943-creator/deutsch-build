import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

class MockJ095Contract implements J095VerificationContract {
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

class MockJ025Contract implements J025LanguageContract {
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
  setUp(() {
    ProductionAcceptanceGate.resetState();
  });

  group('ProductionAcceptanceGate - evaluate', () {
    test('missing mandatory evidence -> notRun', () {
      final contract = MockJ095Contract()..hasMandatoryEvidence = false;
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.notRun));
      expect(result.message, equals('Missing mandatory evidence'));
    });

    test('stale evidence -> notRun', () {
      final contract = MockJ095Contract()..hasStaleEvidence = true;
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.notRun));
      expect(result.message, equals('Stale verification results'));
    });

    test('null J095 contract -> notRun', () {
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: null,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.notRun));
      expect(result.message, equals('Missing verification contract'));
    });

    test('base app readiness fails -> blocked', () {
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: false, // This makes verifyAppReadiness fail
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: MockJ095Contract(),
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.blocked));
      expect(result.message, equals('Critical app readiness missing'));
    });

    test('new Dart errors -> failed', () {
      final contract = MockJ095Contract()..hasNewDartErrors = true;
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.failed));
      expect(result.message, equals('Verification regressions detected'));
    });

    test('memory regression -> failed', () {
      final contract = MockJ095Contract()..hasMemoryRegression = true;
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.failed));
    });

    test('FTS5 regression -> failed', () {
      final contract = MockJ095Contract()..hasFTS5Regression = true;
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.failed));
    });

    test('corrupted storage -> failed', () {
      final contract = MockJ095Contract()..hasCorruptStorage = true;
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.failed));
      expect(result.message, equals('Corrupted storage'));
    });

    test('failed startup recovery -> failed', () {
      final contract = MockJ095Contract()..isNormalStartupVerified = false;
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.failed));
      expect(result.message, equals('Failed startup recovery'));
    });

    test('safe mode behavior not verified -> failed', () {
      final contract = MockJ095Contract()..isSafeModeBehaviorVerified = false;
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.failed));
    });

    test('missing integrity evidence for a language -> blocked', () {
      final lang = MockJ025Contract()..hasLocalPackEvidence = false;
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: MockJ095Contract(),
        languages: [lang],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.blocked));
      expect(result.message, equals('Missing integrity evidence for a language'));
    });

    test('unsupported language claims (metadata only) -> blocked', () {
      final lang = MockJ025Contract()..isMetadataOnly = true;
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: MockJ095Contract(),
        languages: [lang],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.blocked));
      expect(result.message, equals('Unsupported language claims (metadata only)'));
    });

    test('optional TTS absent -> passed with degraded features', () {
      final optional = MockOptionalFeatureContract()..isTtsAvailable = false;
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: MockJ095Contract(),
        languages: [MockJ025Contract()],
        optionalFeatures: optional,
      );
      expect(result.outcome, equals(GateOutcome.passed));
      expect(result.isDegraded, isTrue);
      expect(result.message, equals('Passed with degraded features'));
      expect(ProductionAcceptanceGate.lastApprovedConfiguration, isNotNull);
    });

    test('all conditions met -> passed', () {
      final result = ProductionAcceptanceGate.evaluate(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: MockJ095Contract(),
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result.outcome, equals(GateOutcome.passed));
      expect(result.isDegraded, isFalse);

      final config = ProductionAcceptanceGate.lastApprovedConfiguration;
      expect(config, isNotNull);
      expect(config!.isOfflineSafe, isTrue);
      expect(config.isStorageGuarded, isTrue);
      expect(config.isLifecycleManaged, isTrue);
    });
  });

  group('ProductionAcceptanceGate - evaluatePromotion (legacy wrapper)', () {
    test('passes legacy test', () {
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: MockJ095Contract(),
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result, equals(PromotionEligibility.approved));
    });

    test('handles legacy degraded test', () {
      final optional = MockOptionalFeatureContract()..isTtsAvailable = false;
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: MockJ095Contract(),
        languages: [MockJ025Contract()],
        optionalFeatures: optional,
      );
      expect(result, equals(PromotionEligibility.degraded));
    });

    test('handles legacy blocked test', () {
      final lang = MockJ025Contract()..hasLocalPackEvidence = false;
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: MockJ095Contract(),
        languages: [lang],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result, equals(PromotionEligibility.blocked));
    });

    test('handles legacy notVerified test', () {
      final contract = MockJ095Contract()..hasStaleEvidence = true;
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result, equals(PromotionEligibility.notVerified));
    });
  });
}
