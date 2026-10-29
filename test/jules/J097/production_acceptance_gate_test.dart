import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

void main() {
  group('ProductionAcceptanceGate', () {
    test('missing evidence returns notVerified', () {
      final result = ProductionAcceptanceGate.evaluatePromotionEligibility(null);
      expect(result, PromotionEligibility.notVerified);
    });

    test('stale evidence returns notVerified', () {
      final evidence = ProductionEvidence(
        isJ025ContractVerified: true,
        isJ095ContractVerified: true,
        hasDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        isNormalStartupVerified: true,
        isSafeModeVerified: true,
        isStorageCorrupt: false,
        isOptionalTTSAvailable: true,
        isLanguagePackLocalEvidenceAvailable: true,
        isMetadataOnlyLanguage: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
      );

      final result = ProductionAcceptanceGate.evaluatePromotionEligibility(evidence);
      expect(result, PromotionEligibility.notVerified);
    });

    test('missing mandatory evidence returns notVerified', () {
      final evidence = ProductionEvidence(
        isJ025ContractVerified: true,
        isJ095ContractVerified: null, // missing
        hasDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        isNormalStartupVerified: true,
        isSafeModeVerified: true,
        isStorageCorrupt: false,
        isOptionalTTSAvailable: true,
        isLanguagePackLocalEvidenceAvailable: true,
        isMetadataOnlyLanguage: false,
        timestamp: DateTime.now(),
      );

      final result = ProductionAcceptanceGate.evaluatePromotionEligibility(evidence);
      expect(result, PromotionEligibility.notVerified);
    });

    test('missing J025 or J095 contract verification returns notVerified', () {
      final evidence = ProductionEvidence(
        isJ025ContractVerified: false,
        isJ095ContractVerified: true,
        hasDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        isNormalStartupVerified: true,
        isSafeModeVerified: true,
        isStorageCorrupt: false,
        isOptionalTTSAvailable: true,
        isLanguagePackLocalEvidenceAvailable: true,
        isMetadataOnlyLanguage: false,
        timestamp: DateTime.now(),
      );

      final result = ProductionAcceptanceGate.evaluatePromotionEligibility(evidence);
      expect(result, PromotionEligibility.notVerified);
    });

    test('failed benchmarks and regressions block promotion', () {
      final evidence = ProductionEvidence(
        isJ025ContractVerified: true,
        isJ095ContractVerified: true,
        hasDartErrors: false,
        hasMemoryRegression: true, // Memory regression
        hasFTS5Regression: false,
        isNormalStartupVerified: true,
        isSafeModeVerified: true,
        isStorageCorrupt: false,
        isOptionalTTSAvailable: true,
        isLanguagePackLocalEvidenceAvailable: true,
        isMetadataOnlyLanguage: false,
        timestamp: DateTime.now(),
      );

      final result = ProductionAcceptanceGate.evaluatePromotionEligibility(evidence);
      expect(result, PromotionEligibility.blocked);
    });

    test('corrupt storage blocks promotion', () {
      final evidence = ProductionEvidence(
        isJ025ContractVerified: true,
        isJ095ContractVerified: true,
        hasDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        isNormalStartupVerified: true,
        isSafeModeVerified: true,
        isStorageCorrupt: true, // Corrupt storage
        isOptionalTTSAvailable: true,
        isLanguagePackLocalEvidenceAvailable: true,
        isMetadataOnlyLanguage: false,
        timestamp: DateTime.now(),
      );

      final result = ProductionAcceptanceGate.evaluatePromotionEligibility(evidence);
      expect(result, PromotionEligibility.blocked);
    });

    test('fatal startup errors blocks promotion', () {
      final evidence = ProductionEvidence(
        isJ025ContractVerified: true,
        isJ095ContractVerified: true,
        hasDartErrors: true, // Dart errors
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        isNormalStartupVerified: false, // Fatal startup error
        isSafeModeVerified: true,
        isStorageCorrupt: false,
        isOptionalTTSAvailable: true,
        isLanguagePackLocalEvidenceAvailable: true,
        isMetadataOnlyLanguage: false,
        timestamp: DateTime.now(),
      );

      final result = ProductionAcceptanceGate.evaluatePromotionEligibility(evidence);
      expect(result, PromotionEligibility.blocked);
    });

    test('metadata only language returns blocked', () {
      final evidence = ProductionEvidence(
        isJ025ContractVerified: true,
        isJ095ContractVerified: true,
        hasDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        isNormalStartupVerified: true,
        isSafeModeVerified: true,
        isStorageCorrupt: false,
        isOptionalTTSAvailable: true,
        isLanguagePackLocalEvidenceAvailable: true,
        isMetadataOnlyLanguage: true,
        timestamp: DateTime.now(),
      );

      final result = ProductionAcceptanceGate.evaluatePromotionEligibility(evidence);
      expect(result, PromotionEligibility.blocked);
    });

    test('valid optional-feature failure (TTS absence) degrades safely', () {
      final evidence = ProductionEvidence(
        isJ025ContractVerified: true,
        isJ095ContractVerified: true,
        hasDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        isNormalStartupVerified: true,
        isSafeModeVerified: true,
        isStorageCorrupt: false,
        isOptionalTTSAvailable: false, // TTS unavailable
        isLanguagePackLocalEvidenceAvailable: true,
        isMetadataOnlyLanguage: false,
        timestamp: DateTime.now(),
      );

      final result = ProductionAcceptanceGate.evaluatePromotionEligibility(evidence);
      expect(result, PromotionEligibility.degraded);
      expect(ProductionAcceptanceGate.lastApprovedEvidence, evidence);
    });

    test('successful verification returns approved', () {
      final evidence = ProductionEvidence(
        isJ025ContractVerified: true,
        isJ095ContractVerified: true,
        hasDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        isNormalStartupVerified: true,
        isSafeModeVerified: true,
        isStorageCorrupt: false,
        isOptionalTTSAvailable: true,
        isLanguagePackLocalEvidenceAvailable: true,
        isMetadataOnlyLanguage: false,
        timestamp: DateTime.now(),
      );

      final result = ProductionAcceptanceGate.evaluatePromotionEligibility(evidence);
      expect(result, PromotionEligibility.approved);
      expect(ProductionAcceptanceGate.lastApprovedEvidence, evidence);
    });

    test('critical errors are never silently overridden', () {
      final evidence = ProductionEvidence(
        isJ025ContractVerified: true,
        isJ095ContractVerified: true,
        hasDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        isNormalStartupVerified: true,
        isSafeModeVerified: true,
        isStorageCorrupt: true, // Corrupt storage - must block
        isOptionalTTSAvailable: false, // TTS missing - should degrade, but block takes precedence
        isLanguagePackLocalEvidenceAvailable: true,
        isMetadataOnlyLanguage: false,
        timestamp: DateTime.now(),
      );

      final result = ProductionAcceptanceGate.evaluatePromotionEligibility(evidence);
      expect(result, PromotionEligibility.blocked); // Must be blocked, not degraded!
    });

    test('public api verifyAppReadiness preserves existing behavior', () {
       expect(ProductionAcceptanceGate.verifyAppReadiness(
         isOfflineSafe: true,
         isStorageGuarded: true,
         isLifecycleManaged: true
       ), isTrue);

       expect(ProductionAcceptanceGate.verifyAppReadiness(
         isOfflineSafe: false,
         isStorageGuarded: true,
         isLifecycleManaged: true
       ), isFalse);
    });
  });
}
