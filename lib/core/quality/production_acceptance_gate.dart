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

abstract class J095VerificationResult {
  bool get hasMemoryRegression;
  bool get hasFTS5Regression;
  bool get isStorageCorrupt;
  bool get isEvidenceStale;
  bool get hasMissingMandatoryEvidence;
}

abstract class J025StartupContract {
  bool get hasNewDartErrors;
  bool get hasNormalStartup;
  bool get hasSafeModeStartup;
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

/// بوابة قبول الجاهزية للإنتاج والمتجر الرسمي
enum PromotionEligibility { approved, degraded, blocked, notVerified }

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
