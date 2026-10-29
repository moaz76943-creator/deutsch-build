enum GateOutcome { passed, failed, blocked, notRun }

enum PromotionEligibility { approved, degraded, blocked, notVerified }

class ApprovedFeatureConfiguration {
  final bool isOfflineSafe;
  final bool isStorageGuarded;
  final bool isLifecycleManaged;
  final DateTime approvalTime;

  const ApprovedFeatureConfiguration({
    required this.isOfflineSafe,
    required this.isStorageGuarded,
    required this.isLifecycleManaged,
    required this.approvalTime,
  });
}

class AcceptanceResult {
  final GateOutcome outcome;
  final String message;
  final ApprovedFeatureConfiguration? configuration;
  final bool isDegraded;

  const AcceptanceResult({
    required this.outcome,
    required this.message,
    this.configuration,
    this.isDegraded = false,
  });
}

abstract class J095VerificationContract {
  bool get hasMandatoryEvidence;
  bool get hasStaleEvidence;
  bool get hasNewDartErrors;
  bool get hasMemoryRegression;
  bool get hasFTS5Regression;
  bool get hasCorruptStorage;
  bool get isNormalStartupVerified;
  bool get isSafeModeBehaviorVerified;
}

abstract class J025LanguageContract {
  String get languageCode;
  bool get hasLocalPackEvidence;
  bool get isMetadataOnly;
}

abstract class OptionalFeatureContract {
  bool get isTtsAvailable;
}

class FeatureConfiguration {
  final List<String> verifiedLanguages;
  final List<String> availableOptionalFeatures;

  const FeatureConfiguration({
    required this.verifiedLanguages,
    required this.availableOptionalFeatures,
  });
}

abstract class J025StartupContract {
  bool get isOfflineSafe;
  bool get isStorageGuarded;
  bool get isLifecycleManaged;
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

  static AcceptanceResult evaluate({
    required bool isOfflineSafe,
    required bool isStorageGuarded,
    required bool isLifecycleManaged,
    required J095VerificationContract? j095contract,
    required List<J025LanguageContract> languages,
    required OptionalFeatureContract optionalFeatures,
  }) {
    if (j095contract == null) {
      return const AcceptanceResult(
          outcome: GateOutcome.notRun, message: 'Missing verification contract');
    }

    if (!j095contract.hasMandatoryEvidence) {
      return const AcceptanceResult(
          outcome: GateOutcome.notRun, message: 'Missing mandatory evidence');
    }

    if (j095contract.hasStaleEvidence) {
      return const AcceptanceResult(
          outcome: GateOutcome.notRun, message: 'Stale verification results');
    }

    if (!verifyAppReadiness(
      isOfflineSafe: isOfflineSafe,
      isStorageGuarded: isStorageGuarded,
      isLifecycleManaged: isLifecycleManaged,
    )) {
      return const AcceptanceResult(
          outcome: GateOutcome.blocked, message: 'Critical app readiness missing');
    }

    if (j095contract.hasCorruptStorage) {
      return const AcceptanceResult(
          outcome: GateOutcome.failed, message: 'Corrupted storage');
    }

    if (!j095contract.isNormalStartupVerified) {
      return const AcceptanceResult(
          outcome: GateOutcome.failed, message: 'Failed startup recovery');
    }

    if (j095contract.hasNewDartErrors ||
        j095contract.hasMemoryRegression ||
        j095contract.hasFTS5Regression ||
        !j095contract.isSafeModeBehaviorVerified) {
      return const AcceptanceResult(
          outcome: GateOutcome.failed, message: 'Verification regressions detected');
    }

    for (var lang in languages) {
      if (!lang.hasLocalPackEvidence) {
        return const AcceptanceResult(
            outcome: GateOutcome.blocked, message: 'Missing integrity evidence for a language');
      }
      if (lang.isMetadataOnly) {
        return const AcceptanceResult(
            outcome: GateOutcome.blocked, message: 'Unsupported language claims (metadata only)');
      }
    }

    final config = ApprovedFeatureConfiguration(
      isOfflineSafe: isOfflineSafe,
      isStorageGuarded: isStorageGuarded,
      isLifecycleManaged: isLifecycleManaged,
      approvalTime: DateTime.now(),
    );

    bool degraded = !optionalFeatures.isTtsAvailable;

    // Also save the new v2 configuration for test compatibility
    _lastApprovedConfiguration = FeatureConfiguration(
      verifiedLanguages: languages.map((e) => e.languageCode).toList(),
      availableOptionalFeatures: optionalFeatures.isTtsAvailable ? ['tts'] : [],
    );

    return AcceptanceResult(
      outcome: GateOutcome.passed,
      message: degraded ? 'Passed with degraded features' : 'All checks passed',
      configuration: config,
      isDegraded: degraded,
    );
  }

  static PromotionEligibility evaluatePromotion({
    J025StartupContract? startupContract,
    J095VerificationResult? verificationResult,
    List<LanguageReadinessEvidence>? languageEvidence,
    List<OptionalFeatureEvidence>? optionalFeatures,

    // Legacy support to preserve public compatibility
    @Deprecated('Use startupContract instead') bool? isOfflineSafe,
    @Deprecated('Use startupContract instead') bool? isStorageGuarded,
    @Deprecated('Use startupContract instead') bool? isLifecycleManaged,
    @Deprecated('Use verificationResult instead') J095VerificationContract? j095contract,
    @Deprecated('Use languageEvidence instead') List<J025LanguageContract>? languages,
    @Deprecated('Use optionalFeatures instead') OptionalFeatureContract? legacyOptionalFeatures,
  }) {
    // Legacy mode bridge
    if (isOfflineSafe != null && isStorageGuarded != null && isLifecycleManaged != null && j095contract != null && languages != null && legacyOptionalFeatures != null) {
      final result = evaluate(
        isOfflineSafe: isOfflineSafe,
        isStorageGuarded: isStorageGuarded,
        isLifecycleManaged: isLifecycleManaged,
        j095contract: j095contract,
        languages: languages,
        optionalFeatures: legacyOptionalFeatures,
      );

      switch (result.outcome) {
        case GateOutcome.passed:
          return result.isDegraded
              ? PromotionEligibility.degraded
              : PromotionEligibility.approved;
        case GateOutcome.notRun:
          return PromotionEligibility.notVerified;
        case GateOutcome.blocked:
        case GateOutcome.failed:
          return PromotionEligibility.blocked;
      }
    }

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
