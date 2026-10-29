enum GateOutcome {
  passed,
  failed,
  blocked,
  notRun,
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

  const J095VerificationResult({
    required this.outcome,
    required this.eligibility,
    required this.reason,
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
  });
}

/// بوابة قبول الجاهزية للإنتاج والمتجر الرسمي
enum PromotionEligibility { approved, degraded, blocked, notVerified }

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
<<<<<<< HEAD
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

    _lastApprovedConfiguration = config;

    bool degraded = !optionalFeatures.isTtsAvailable;

    return AcceptanceResult(
      outcome: GateOutcome.passed,
      message: degraded ? 'Passed with degraded features' : 'All checks passed',
      configuration: config,
      isDegraded: degraded,
    );
  }

  @Deprecated('Use evaluate() instead')
  static PromotionEligibility evaluatePromotion({
    required bool isOfflineSafe,
    required bool isStorageGuarded,
    required bool isLifecycleManaged,
    required J095VerificationContract? j095contract,
    required List<J025LanguageContract> languages,
    required OptionalFeatureContract optionalFeatures,
  }) {
    final result = evaluate(
      isOfflineSafe: isOfflineSafe,
      isStorageGuarded: isStorageGuarded,
      isLifecycleManaged: isLifecycleManaged,
      j095contract: j095contract,
      languages: languages,
      optionalFeatures: optionalFeatures,
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
=======
    final contract = J025StartupContract(
      isOfflineSafe: isOfflineSafe,
      isStorageGuarded: isStorageGuarded,
      isLifecycleManaged: isLifecycleManaged,
    );
    final result = evaluateReadiness(contract);
    return result.outcome @override
  == GateOutcome.passed;
  }

  J095VerificationResult evaluateReadiness(
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

  PromotionEligibility evaluatePromotion({
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
>>>>>>> origin/main

    _lastApprovedConfiguration = FeatureConfiguration(
      verifiedLanguages: verifiedLangs,
      availableOptionalFeatures: availableFeatures,
    );

    return isDegraded
        ? PromotionEligibility.degraded
        : PromotionEligibility.approved;
  }
}
