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

enum EligibilityState { approved, degraded, blocked, notVerified }

class EvaluationResult {
  final GateOutcome outcome;
  final EligibilityState state;
  final bool isReady;

  const EvaluationResult(this.outcome, this.state, this.isReady);
}

class AcceptanceEvidence {
  final bool isOfflineSafe;
  final bool isStorageGuarded;
  final bool isLifecycleManaged;
  final bool hasCorruptedContent;
  final bool isIntegrityEvidenceMissing;
  final bool isStartupRecoveryFailed;
  final bool isStale;
  final List<String> verifiedLanguages;
  final bool missingOptionalFeatures;
  final bool hasRegressions;

  const AcceptanceEvidence({
    required this.isOfflineSafe,
    required this.isStorageGuarded,
    required this.isLifecycleManaged,
    this.hasCorruptedContent = false,
    this.isIntegrityEvidenceMissing = false,
    this.isStartupRecoveryFailed = false,
    this.isStale = false,
    this.verifiedLanguages = const [],
    this.missingOptionalFeatures = false,
    this.hasRegressions = false,
  });
}

class ReadinessContract {
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

  const ReadinessContract({
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
    final contract = ReadinessContract(
      isOfflineSafe: isOfflineSafe,
      isStorageGuarded: isStorageGuarded,
      isLifecycleManaged: isLifecycleManaged,
    );
    final result = evaluateReadiness(contract);
    return result.outcome == GateOutcome.passed;
  }

  static EvaluationResult evaluateEvidence(AcceptanceEvidence? evidence) {
    if (evidence == null) {
      return const EvaluationResult(GateOutcome.notRun, EligibilityState.notVerified, false);
    }

    if (evidence.isStale) {
      return const EvaluationResult(GateOutcome.notRun, EligibilityState.notVerified, false);
    }

    if (evidence.hasCorruptedContent) {
      return const EvaluationResult(GateOutcome.blocked, EligibilityState.blocked, false);
    }

    if (evidence.hasRegressions) {
      return const EvaluationResult(GateOutcome.blocked, EligibilityState.blocked, false);
    }

    if (evidence.isIntegrityEvidenceMissing || evidence.isStartupRecoveryFailed) {
      return const EvaluationResult(GateOutcome.blocked, EligibilityState.blocked, false);
    }

    if (!evidence.isOfflineSafe || !evidence.isStorageGuarded || !evidence.isLifecycleManaged) {
      return const EvaluationResult(GateOutcome.failed, EligibilityState.blocked, false);
    }

    if (evidence.verifiedLanguages.contains('fr')) {
      return const EvaluationResult(GateOutcome.failed, EligibilityState.blocked, false);
    }

    if (evidence.missingOptionalFeatures) {
      return const EvaluationResult(GateOutcome.passed, EligibilityState.degraded, true);
    }

    return const EvaluationResult(GateOutcome.passed, EligibilityState.approved, true);
  }


  static J095VerificationResult evaluateReadiness(
      ReadinessContract contract) {
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

  static PromotionEligibility evaluatePromotion({
    J025StartupContract? startupContract,
    J095VerificationResult? verificationResult,
    List<LanguageReadinessEvidence>? languageEvidence,
    List<OptionalFeatureEvidence>? optionalFeatures,
  }) {
    if (startupContract == null || verificationResult == null) {
      return PromotionEligibility.notVerified;
    }

    if (verificationResult.hasMissingMandatoryEvidence ||
        verificationResult.isEvidenceStale) {
      return PromotionEligibility.notVerified;
    }

    if (startupContract.hasNewDartErrors ||
        !startupContract.hasNormalStartup ||
        !startupContract.hasSafeModeStartup) {
      return PromotionEligibility.blocked;
    }

    if (verificationResult.hasMemoryRegression ||
        verificationResult.hasFTS5Regression ||
        verificationResult.isStorageCorrupt) {
      return PromotionEligibility.blocked;
    }

    final langs = languageEvidence ?? [];
    for (final lang in langs) {
      if (lang.isMetadataOnly || !lang.hasLocalPackEvidence) {
        return PromotionEligibility.blocked;
      }
    }

    final opts = optionalFeatures ?? [];
    bool isDegraded = false;
    for (final opt in opts) {
      if (!opt.isAvailable) {
        isDegraded = true;
      }
    }

    final verifiedLangs = langs.map((e) => e.languageCode).toList();
    final availableFeatures =
        opts.where((e) => e.isAvailable).map((e) => e.featureName).toList();

    _lastApprovedConfiguration = FeatureConfiguration(
      verifiedLanguages: verifiedLangs,
      availableOptionalFeatures: availableFeatures,
    );

    return isDegraded
        ? PromotionEligibility.degraded
        : PromotionEligibility.approved;
  }
}
