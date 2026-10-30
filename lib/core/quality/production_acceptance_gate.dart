enum GateOutcome { passed, failed, blocked, notRun }

enum PromotionEligibility { approved, degraded, blocked, notVerified }

class AcceptanceResult {
  final GateOutcome outcome;
  final PromotionEligibility eligibility;
  final String reason;
  final FeatureConfiguration? configuration;

  const AcceptanceResult({
    required this.outcome,
    required this.eligibility,
    required this.reason,
    this.configuration,
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
  });
}

abstract class J025StartupContract {
  bool get hasNewDartErrors;
  bool get hasNormalStartup;
  bool get hasSafeModeStartup;
}

abstract class J095VerificationResult {
  bool get hasMemoryRegression;
  bool get hasFTS5Regression;
  bool get isStorageCorrupt;
  bool get isEvidenceStale;
  bool get hasMissingMandatoryEvidence;
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

class ProductionAcceptanceGate {
  static FeatureConfiguration? _lastApprovedConfiguration;
  static FeatureConfiguration? get lastApprovedConfiguration =>
      _lastApprovedConfiguration;

  static bool verifyAppReadiness({
    required bool isOfflineSafe,
    required bool isStorageGuarded,
    required bool isLifecycleManaged,
  }) {
    return isOfflineSafe && isStorageGuarded && isLifecycleManaged;
  }

  static AcceptanceResult evaluateReadiness(ReadinessContract contract) {
    if (!contract.hasExecutedTests) {
      return const AcceptanceResult(
        outcome: GateOutcome.notRun,
        eligibility: PromotionEligibility.notVerified,
        reason: 'Verification tests have not executed.',
      );
    }

    if (contract.isVerificationStale) {
      return const AcceptanceResult(
        outcome: GateOutcome.notRun,
        eligibility: PromotionEligibility.notVerified,
        reason: 'Verification results are stale.',
      );
    }

    if (contract.isIntegrityEvidenceMissing) {
      return const AcceptanceResult(
        outcome: GateOutcome.blocked,
        eligibility: PromotionEligibility.blocked,
        reason: 'Missing integrity evidence.',
      );
    }

    if (contract.isContentCorrupted) {
      return const AcceptanceResult(
        outcome: GateOutcome.failed,
        eligibility: PromotionEligibility.blocked,
        reason: 'Corrupted content detected.',
      );
    }

    if (contract.isStartupRecoveryFailed) {
      return const AcceptanceResult(
        outcome: GateOutcome.failed,
        eligibility: PromotionEligibility.blocked,
        reason: 'Startup recovery failed.',
      );
    }

    if (!verifyAppReadiness(
      isOfflineSafe: contract.isOfflineSafe,
      isStorageGuarded: contract.isStorageGuarded,
      isLifecycleManaged: contract.isLifecycleManaged,
    )) {
      return const AcceptanceResult(
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
      return const AcceptanceResult(
        outcome: GateOutcome.failed,
        eligibility: PromotionEligibility.blocked,
        reason: 'Unsupported language claims detected.',
      );
    }

    final config = FeatureConfiguration(
      verifiedLanguages: contract.verifiedDictionaries.toList(),
      availableOptionalFeatures: contract.hasOptionalAudio ? ['audio'] : [],
    );

    _lastApprovedConfiguration = config;

    if (!contract.hasOptionalAudio) {
      return AcceptanceResult(
        outcome: GateOutcome.passed,
        eligibility: PromotionEligibility.degraded,
        reason: 'Passed with degraded optional features.',
        configuration: config,
      );
    }

    return AcceptanceResult(
      outcome: GateOutcome.passed,
      eligibility: PromotionEligibility.approved,
      reason: 'All mandatory and optional checks passed.',
      configuration: config,
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
