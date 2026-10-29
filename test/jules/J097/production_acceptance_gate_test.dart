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

  group('ProductionAcceptanceGate - evaluatePromotion', () {
    test('missing mandatory evidence -> notVerified', () {
      final contract = MockJ095Contract()..hasMandatoryEvidence = false;
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

    test('stale evidence -> notVerified', () {
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

    test('null J095 contract -> notVerified', () {
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: null,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result, equals(PromotionEligibility.notVerified));
    });

    test('base app readiness fails -> blocked', () {
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: false, // This makes verifyAppReadiness fail
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: MockJ095Contract(),
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result, equals(PromotionEligibility.blocked));
    });

    test('new Dart errors -> blocked', () {
      final contract = MockJ095Contract()..hasNewDartErrors = true;
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result, equals(PromotionEligibility.blocked));
    });

    test('memory regression -> blocked', () {
      final contract = MockJ095Contract()..hasMemoryRegression = true;
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result, equals(PromotionEligibility.blocked));
    });

    test('FTS5 regression -> blocked', () {
      final contract = MockJ095Contract()..hasFTS5Regression = true;
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result, equals(PromotionEligibility.blocked));
    });

    test('corrupt storage -> blocked', () {
      final contract = MockJ095Contract()..hasCorruptStorage = true;
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result, equals(PromotionEligibility.blocked));
    });

    test('normal startup not verified -> blocked', () {
      final contract = MockJ095Contract()..isNormalStartupVerified = false;
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result, equals(PromotionEligibility.blocked));
    });

    test('safe mode behavior not verified -> blocked', () {
      final contract = MockJ095Contract()..isSafeModeBehaviorVerified = false;
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: contract,
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result, equals(PromotionEligibility.blocked));
    });

    test('language pack missing local evidence -> blocked', () {
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

    test('language is metadata only -> blocked', () {
      final lang = MockJ025Contract()..isMetadataOnly = true;
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

    test('optional TTS absent -> degraded (but not blocked)', () {
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
      expect(ProductionAcceptanceGate.lastApprovedConfiguration, isNotNull);
    });

    test('all conditions met -> approved', () {
      final result = ProductionAcceptanceGate.evaluatePromotion(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        j095contract: MockJ095Contract(),
        languages: [MockJ025Contract()],
        optionalFeatures: MockOptionalFeatureContract(),
      );
      expect(result, equals(PromotionEligibility.approved));

      final config = ProductionAcceptanceGate.lastApprovedConfiguration;
      expect(config, isNotNull);
      expect(config!.isOfflineSafe, isTrue);
      expect(config.isStorageGuarded, isTrue);
      expect(config.isLifecycleManaged, isTrue);
    });
  });
}
