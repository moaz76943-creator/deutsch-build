import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

class MockJ025StartupContract implements J025StartupContract {
  @override
  final bool hasNewDartErrors;
  @override
  final bool hasNormalStartup;
  @override
  final bool hasSafeModeStartup;
  @override
  final bool isOfflineSafe;
  @override
  final bool isStorageGuarded;
  @override
  final bool isLifecycleManaged;

  MockJ025StartupContract({
    this.hasNewDartErrors = false,
    this.hasNormalStartup = true,
    this.hasSafeModeStartup = true,
    this.isOfflineSafe = true,
    this.isStorageGuarded = true,
    this.isLifecycleManaged = true,
  });
}

class MockJ095VerificationResult implements J095VerificationResult {
  @override
  final bool hasMemoryRegression;
  @override
  final bool hasFTS5Regression;
  @override
  final bool isStorageCorrupt;
  @override
  final bool isEvidenceStale;
  @override
  final bool hasMissingMandatoryEvidence;

  MockJ095VerificationResult({
    this.hasMemoryRegression = false,
    this.hasFTS5Regression = false,
    this.isStorageCorrupt = false,
    this.isEvidenceStale = false,
    this.hasMissingMandatoryEvidence = false,
  });
}

class MockLanguageReadinessEvidence implements LanguageReadinessEvidence {
  @override
  final String languageCode;
  @override
  final bool hasLocalPackEvidence;
  @override
  final bool isMetadataOnly;

  MockLanguageReadinessEvidence({
    required this.languageCode,
    this.hasLocalPackEvidence = true,
    this.isMetadataOnly = false,
  });
}

class MockOptionalFeatureEvidence implements OptionalFeatureEvidence {
  @override
  final String featureName;
  @override
  final bool isAvailable;

  MockOptionalFeatureEvidence({
    required this.featureName,
    this.isAvailable = true,
  });
}

void main() {
  group('ProductionAcceptanceGate', () {
    late ProductionAcceptanceGate gate;

    setUp(() {
      gate = ProductionAcceptanceGate();
    });

    test('returns notRun if contracts are missing', () {
      final result = gate.evaluateReadiness(null, null, [], []);
      expect(result.outcome, GateOutcome.notRun);
      expect(result.eligibility, PromotionEligibility.notVerified);
    });

    test('returns passed if everything is verified', () {
      final result = gate.evaluateReadiness(
        MockJ025StartupContract(),
        MockJ095VerificationResult(),
        [MockLanguageReadinessEvidence(languageCode: 'en')],
        [MockOptionalFeatureEvidence(featureName: 'tts')],
      );
      expect(result.outcome, GateOutcome.passed);
      expect(result.eligibility, PromotionEligibility.approved);
    });

    test('returns blocked if missing mandatory evidence', () {
      final result = gate.evaluateReadiness(
        MockJ025StartupContract(),
        MockJ095VerificationResult(hasMissingMandatoryEvidence: true),
        [],
        [],
      );
      expect(result.outcome, GateOutcome.notRun);
      expect(result.eligibility, PromotionEligibility.notVerified);
    });

    test('returns blocked if evidence is stale', () {
      final result = gate.evaluateReadiness(
        MockJ025StartupContract(),
        MockJ095VerificationResult(isEvidenceStale: true),
        [],
        [],
      );
      expect(result.outcome, GateOutcome.notRun);
      expect(result.eligibility, PromotionEligibility.notVerified);
    });

    test('returns blocked if storage is corrupt', () {
      final result = gate.evaluateReadiness(
        MockJ025StartupContract(),
        MockJ095VerificationResult(isStorageCorrupt: true),
        [],
        [],
      );
      expect(result.outcome, GateOutcome.blocked);
      expect(result.eligibility, PromotionEligibility.blocked);
    });

    test('returns blocked if a language is metadata only', () {
      final result = gate.evaluateReadiness(
        MockJ025StartupContract(),
        MockJ095VerificationResult(),
        [MockLanguageReadinessEvidence(languageCode: 'en', isMetadataOnly: true)],
        [],
      );
      expect(result.outcome, GateOutcome.blocked);
      expect(result.eligibility, PromotionEligibility.blocked);
    });

    test('degrades gracefully for missing optional features', () {
      final result = gate.evaluateReadiness(
        MockJ025StartupContract(),
        MockJ095VerificationResult(),
        [],
        [MockOptionalFeatureEvidence(featureName: 'tts', isAvailable: false)],
      );
      expect(result.outcome, GateOutcome.passed);
      expect(result.eligibility, PromotionEligibility.degraded);
    });

    test('preserves backward compatibility with verifyAppReadiness', () {
      // ignore: deprecated_member_use_from_same_package
      final ready = ProductionAcceptanceGate.verifyAppReadiness(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      expect(ready, isTrue);
    });
  });
}
