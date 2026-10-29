enum GateOutcome {
  passed,
  failed,
  blocked,
  notRun,
}

class AcceptanceResult {
  final GateOutcome outcome;
  final String message;
  final FeatureConfiguration? configuration;
  final bool isDegraded;

  const AcceptanceResult({
    required this.outcome,
    required this.message,
    this.configuration,
    this.isDegraded = false,
  });
}

enum PromotionEligibility { approved, degraded, blocked, notVerified }

abstract class J025StartupContract {
  bool get hasNewDartErrors;
  bool get hasNormalStartup;
  bool get hasSafeModeStartup;
  bool get isOfflineSafe;
  bool get isStorageGuarded;
  bool get isLifecycleManaged;
  bool get isContentCorrupted;
  bool get isIntegrityEvidenceMissing;
  bool get isStartupRecoveryFailed;
  bool get isVerificationStale;
  Set<String> get registeredLanguages;
  Set<String> get verifiedDictionaries;
  bool get hasOptionalAudio;
  bool get hasExecutedTests;
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

  static AcceptanceResult evaluateReadiness(J025StartupContract contract) {
    if (!contract.hasExecutedTests) {
      return const AcceptanceResult(
        outcome: GateOutcome.notRun,
        message: 'Verification tests have not executed.',
      );
    }

    if (contract.isVerificationStale) {
      return const AcceptanceResult(
        outcome: GateOutcome.notRun,
        message: 'Verification results are stale.',
      );
    }

    if (contract.isIntegrityEvidenceMissing) {
      return const AcceptanceResult(
        outcome: GateOutcome.blocked,
        message: 'Missing integrity evidence.',
      );
    }

    if (contract.isContentCorrupted) {
      return const AcceptanceResult(
        outcome: GateOutcome.failed,
        message: 'Corrupted content detected.',
      );
    }

    if (contract.isStartupRecoveryFailed) {
      return const AcceptanceResult(
        outcome: GateOutcome.failed,
        message: 'Startup recovery failed.',
      );
    }

    if (!contract.isOfflineSafe ||
        !contract.isStorageGuarded ||
        !contract.isLifecycleManaged) {
      return const AcceptanceResult(
        outcome: GateOutcome.failed,
        message: 'Mandatory infrastructure checks failed.',
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
        message: 'Unsupported language claims detected.',
      );
    }

    if (!contract.hasOptionalAudio) {
      return const AcceptanceResult(
        outcome: GateOutcome.passed,
        message: 'Passed with degraded optional features.',
        isDegraded: true,
      );
    }

    return const AcceptanceResult(
      outcome: GateOutcome.passed,
      message: 'All mandatory and optional checks passed.',
    );
  }

  @Deprecated('Use evaluateReadiness() instead')
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
