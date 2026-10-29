import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

void main() {
  group('ProductionAcceptanceGate - notVerified states', () {
    test('returns notVerified on null evidence', () {
      expect(ProductionAcceptanceGate.evaluateEligibility(null), EligibilityState.notVerified);
    });

    test('returns notVerified on missing mandatory evidence', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasJ025Contract: true,
        hasJ095Contract: true,
        hasNewDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        verifiedNormalStartup: true,
        verifiedSafeModeStartup: true,
        isEvidenceStale: false,
        isMissingMandatoryEvidence: true,
        isOptionalTtsAvailable: true,
        verifiedLocalLanguagePacks: ['de'],
        metadataOnlyLanguages: [],
      );
      expect(ProductionAcceptanceGate.evaluateEligibility(evidence), EligibilityState.notVerified);
    });

    test('returns notVerified on stale evidence', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasJ025Contract: true,
        hasJ095Contract: true,
        hasNewDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        verifiedNormalStartup: true,
        verifiedSafeModeStartup: true,
        isEvidenceStale: true,
        isMissingMandatoryEvidence: false,
        isOptionalTtsAvailable: true,
        verifiedLocalLanguagePacks: ['de'],
        metadataOnlyLanguages: [],
      );
      expect(ProductionAcceptanceGate.evaluateEligibility(evidence), EligibilityState.notVerified);
    });

    test('returns notVerified when J025 or J095 are missing', () {
      final noJ025 = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasJ025Contract: false,
        hasJ095Contract: true,
        hasNewDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        verifiedNormalStartup: true,
        verifiedSafeModeStartup: true,
        isEvidenceStale: false,
        isMissingMandatoryEvidence: false,
        isOptionalTtsAvailable: true,
        verifiedLocalLanguagePacks: ['de'],
        metadataOnlyLanguages: [],
      );

      final noJ095 = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasJ025Contract: true,
        hasJ095Contract: false,
        hasNewDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        verifiedNormalStartup: true,
        verifiedSafeModeStartup: true,
        isEvidenceStale: false,
        isMissingMandatoryEvidence: false,
        isOptionalTtsAvailable: true,
        verifiedLocalLanguagePacks: ['de'],
        metadataOnlyLanguages: [],
      );

      expect(ProductionAcceptanceGate.evaluateEligibility(noJ025), EligibilityState.notVerified);
      expect(ProductionAcceptanceGate.evaluateEligibility(noJ095), EligibilityState.notVerified);
    });
  });

  group('ProductionAcceptanceGate - blocked states', () {
    test('returns blocked on critical failures (Dart errors, Regressions, corrupted storage)', () {
      final noOffline = AcceptanceEvidence(
        isOfflineSafe: false,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasJ025Contract: true,
        hasJ095Contract: true,
        hasNewDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        verifiedNormalStartup: true,
        verifiedSafeModeStartup: true,
        isEvidenceStale: false,
        isMissingMandatoryEvidence: false,
        isOptionalTtsAvailable: true,
        verifiedLocalLanguagePacks: ['de'],
        metadataOnlyLanguages: [],
      );

      final hasDartErrors = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasJ025Contract: true,
        hasJ095Contract: true,
        hasNewDartErrors: true,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        verifiedNormalStartup: true,
        verifiedSafeModeStartup: true,
        isEvidenceStale: false,
        isMissingMandatoryEvidence: false,
        isOptionalTtsAvailable: true,
        verifiedLocalLanguagePacks: ['de'],
        metadataOnlyLanguages: [],
      );

      final hasMemoryRegression = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasJ025Contract: true,
        hasJ095Contract: true,
        hasNewDartErrors: false,
        hasMemoryRegression: true,
        hasFTS5Regression: false,
        verifiedNormalStartup: true,
        verifiedSafeModeStartup: true,
        isEvidenceStale: false,
        isMissingMandatoryEvidence: false,
        isOptionalTtsAvailable: true,
        verifiedLocalLanguagePacks: ['de'],
        metadataOnlyLanguages: [],
      );

      final corruptStorage = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: false,
        isLifecycleManaged: true,
        hasJ025Contract: true,
        hasJ095Contract: true,
        hasNewDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        verifiedNormalStartup: true,
        verifiedSafeModeStartup: true,
        isEvidenceStale: false,
        isMissingMandatoryEvidence: false,
        isOptionalTtsAvailable: true,
        verifiedLocalLanguagePacks: ['de'],
        metadataOnlyLanguages: [],
      );

      expect(ProductionAcceptanceGate.evaluateEligibility(noOffline), EligibilityState.blocked);
      expect(ProductionAcceptanceGate.evaluateEligibility(hasDartErrors), EligibilityState.blocked);
      expect(ProductionAcceptanceGate.evaluateEligibility(hasMemoryRegression), EligibilityState.blocked);
      expect(ProductionAcceptanceGate.evaluateEligibility(corruptStorage), EligibilityState.blocked);
    });
  });

  group('ProductionAcceptanceGate - degraded and approved states, rollback and configuration', () {
    test('returns degraded when optional TTS is unavailable', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasJ025Contract: true,
        hasJ095Contract: true,
        hasNewDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        verifiedNormalStartup: true,
        verifiedSafeModeStartup: true,
        isEvidenceStale: false,
        isMissingMandatoryEvidence: false,
        isOptionalTtsAvailable: false,
        verifiedLocalLanguagePacks: ['de'],
        metadataOnlyLanguages: [],
      );

      expect(ProductionAcceptanceGate.evaluateEligibility(evidence), EligibilityState.degraded);
      expect(ProductionAcceptanceGate.lastApprovedConfiguration, isNotNull);
      expect(ProductionAcceptanceGate.lastApprovedConfiguration!.isOptionalTtsAvailable, false);
    });

    test('returns approved when fully verified', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasJ025Contract: true,
        hasJ095Contract: true,
        hasNewDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        verifiedNormalStartup: true,
        verifiedSafeModeStartup: true,
        isEvidenceStale: false,
        isMissingMandatoryEvidence: false,
        isOptionalTtsAvailable: true,
        verifiedLocalLanguagePacks: ['de', 'ar'],
        metadataOnlyLanguages: [],
      );

      expect(ProductionAcceptanceGate.evaluateEligibility(evidence), EligibilityState.approved);
      expect(ProductionAcceptanceGate.lastApprovedConfiguration, evidence);
    });

    test('returns blocked if a local language pack is not production ready', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasJ025Contract: true,
        hasJ095Contract: true,
        hasNewDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        verifiedNormalStartup: true,
        verifiedSafeModeStartup: true,
        isEvidenceStale: false,
        isMissingMandatoryEvidence: false,
        isOptionalTtsAvailable: true,
        verifiedLocalLanguagePacks: ['de', 'fr'], // fr is assetsReady, not productionReady
        metadataOnlyLanguages: [],
      );

      expect(ProductionAcceptanceGate.evaluateEligibility(evidence), EligibilityState.blocked);
    });

    test('returns blocked if there are metadata-only languages', () {
      final evidence = AcceptanceEvidence(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
        hasJ025Contract: true,
        hasJ095Contract: true,
        hasNewDartErrors: false,
        hasMemoryRegression: false,
        hasFTS5Regression: false,
        verifiedNormalStartup: true,
        verifiedSafeModeStartup: true,
        isEvidenceStale: false,
        isMissingMandatoryEvidence: false,
        isOptionalTtsAvailable: true,
        verifiedLocalLanguagePacks: ['de'],
        metadataOnlyLanguages: ['en'],
      );

      expect(ProductionAcceptanceGate.evaluateEligibility(evidence), EligibilityState.blocked);
    });

    test('backwards compatibility: verifyAppReadiness', () {
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
  });
}
