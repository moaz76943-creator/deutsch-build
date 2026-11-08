enum GateOutcome {
  passed,
  failed,
  blocked,
  notRun,
}

enum PromotionEligibility {
  approved,
  degraded,
  blocked,
  notVerified,
}

class J095VerificationResult {
  final GateOutcome outcome;
  final PromotionEligibility eligibility;
  final String reason;
  final bool hasMemoryRegression;
  final bool hasFTS5Regression;
  final bool isStorageCorrupt;
  final bool isEvidenceStale;
  final bool hasMissingMandatoryEvidence;

  const J095VerificationResult({
    required this.outcome,
    required this.eligibility,
    required this.reason,
    this.hasMemoryRegression = false,
    this.hasFTS5Regression = false,
    this.isStorageCorrupt = false,
    this.isEvidenceStale = false,
    this.hasMissingMandatoryEvidence = false,
  });
}

class J025StartupContract {
  final bool isOfflineSafe;
  final bool isStorageGuarded;
  final bool isLifecycleManaged;

  final bool isContentCorrupted;
  final bool isIntegrityEvidenceMissing;
  final bool isStartupRecoveryFailed;
  final bool isVerificationStale;

  final Set<String> registeredLanguages;
  final Set<String> verifiedDictionaries;

  final bool hasOptionalAudio;
  final bool hasExecutedTests;

  final bool hasNewDartErrors;
  final bool hasNormalStartup;
  final bool hasSafeModeStartup;

  const J025StartupContract({
    required this.isOfflineSafe,
    required this.isStorageGuarded,
    required this.isLifecycleManaged,
    this.isContentCorrupted = false,
    this.isIntegrityEvidenceMissing = false,
    this.isStartupRecoveryFailed = false,
    this.isVerificationStale = false,
    this.registeredLanguages = const {},
    this.verifiedDictionaries = const {},
    this.hasOptionalAudio = true,
    this.hasExecutedTests = true,
    this.hasNewDartErrors = false,
    this.hasNormalStartup = true,
    this.hasSafeModeStartup = true,
  });
}

abstract class LanguageReadinessEvidence {
  String get languageCode;
  bool get hasLocalPackEvidence;
  bool get isMetadataOnly;
}

abstract class OptionalFeatureEvidence {
  String get featureName;
  bool get isAvailable;
}

class FeatureConfiguration {
  final List<String> verifiedLanguages;
  final List<String> availableOptionalFeatures;

  const FeatureConfiguration({
    required this.verifiedLanguages,
    required this.availableOptionalFeatures,
  });
}

/// Production readiness gate. One concrete contract serves both the
/// evidence-backed readiness check and promotion decisions.
class ProductionAcceptanceGate {
  static FeatureConfiguration? _lastApprovedConfiguration;
  static FeatureConfiguration? get lastApprovedConfiguration =>
      _lastApprovedConfiguration;

  static bool verifyAppReadiness({
    required bool isOfflineSafe,
    required bool isStorageGuarded,
    required bool isLifecycleManaged,
  }) {
    final contract = J025StartupContract(
      isOfflineSafe: isOfflineSafe,
      isStorageGuarded: isStorageGuarded,
      isLifecycleManaged: isLifecycleManaged,
    );
    final result = evaluateReadiness(contract);
    return result.outcome == GateOutcome.passed;
  }

  static J095VerificationResult evaluateReadiness(
      J025StartupContract contract) {
    if (!contract.hasExecutedTests) {
      return const J095VerificationResult(
        outcome: GateOutcome.notRun,
        eligibility: PromotionEligibility.notVerified,
        reason: 'Verification tests have not executed.',
      );
    }

    if (contract.isVerificationStale) {
      return const J095VerificationResult(
        outcome: GateOutcome.notRun,
        eligibility: PromotionEligibility.notVerified,
        reason: 'Verification results are stale.',
      );
    }

    if (contract.isIntegrityEvidenceMissing) {
      return const J095VerificationResult(
        outcome: GateOutcome.blocked,
        eligibility: PromotionEligibility.blocked,
        reason: 'Missing integrity evidence.',
      );
    }

    if (contract.isContentCorrupted) {
      return const J095VerificationResult(
        outcome: GateOutcome.failed,
        eligibility: PromotionEligibility.blocked,
        reason: 'Corrupted content detected.',
      );
    }

    if (contract.isStartupRecoveryFailed) {
      return const J095VerificationResult(
        outcome: GateOutcome.failed,
        eligibility: PromotionEligibility.blocked,
        reason: 'Startup recovery failed.',
      );
    }

    if (!contract.isOfflineSafe ||
        !contract.isStorageGuarded ||
        !contract.isLifecycleManaged) {
      return const J095VerificationResult(
        outcome: GateOutcome.failed,
        eligibility: PromotionEligibility.blocked,
        reason: 'Mandatory infrastructure checks failed.',
      );
    }

    bool hasUnsupportedClaims = false;
    for (final lang in contract.registeredLanguages) {
      if (!contract.verifiedDictionaries.contains(lang)) {
        hasUnsupportedClaims = true;
        break;
      }
    }

    if (hasUnsupportedClaims) {
      return const J095VerificationResult(
        outcome: GateOutcome.failed,
        eligibility: PromotionEligibility.blocked,
        reason: 'Unsupported language claims detected.',
      );
    }

    if (!contract.hasOptionalAudio) {
      return const J095VerificationResult(
        outcome: GateOutcome.passed,
        eligibility: PromotionEligibility.degraded,
        reason: 'Passed with degraded optional features.',
      );
    }

    return const J095VerificationResult(
      outcome: GateOutcome.passed,
      eligibility: PromotionEligibility.approved,
      reason: 'All mandatory and optional checks passed.',
    );
  }

}
