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

class AcceptanceResult {
  final GateOutcome outcome;
  final PromotionEligibility eligibility;
  final String reason;

  const AcceptanceResult({
    required this.outcome,
    required this.eligibility,
    required this.reason,
  });
}

abstract class J025StartupContract {
  bool get hasNewDartErrors;
  bool get hasNormalStartup;
  bool get hasSafeModeStartup;
  bool get isOfflineSafe;
  bool get isStorageGuarded;
  bool get isLifecycleManaged;
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
  @Deprecated('Use evaluateReadiness instead')
  static bool verifyAppReadiness({
    required bool isOfflineSafe,
    required bool isStorageGuarded,
    required bool isLifecycleManaged,
  }) {
    return isOfflineSafe && isStorageGuarded && isLifecycleManaged;
  }

  AcceptanceResult evaluateReadiness(
    J025StartupContract? startupContract,
    J095VerificationResult? verificationResult,
    List<LanguageReadinessEvidence> languageEvidence,
    List<OptionalFeatureEvidence> optionalFeatures,
  ) {
    if (startupContract == null || verificationResult == null) {
      return const AcceptanceResult(
        outcome: GateOutcome.notRun,
        eligibility: PromotionEligibility.notVerified,
        reason: 'Missing mandatory evidence',
      );
    }

    if (verificationResult.hasMissingMandatoryEvidence ||
        verificationResult.isEvidenceStale) {
      return const AcceptanceResult(
        outcome: GateOutcome.notRun,
        eligibility: PromotionEligibility.notVerified,
        reason: 'Missing or stale verification evidence',
      );
    }

    if (startupContract.hasNewDartErrors ||
        !startupContract.hasNormalStartup ||
        !startupContract.hasSafeModeStartup) {
      return const AcceptanceResult(
        outcome: GateOutcome.blocked,
        eligibility: PromotionEligibility.blocked,
        reason: 'Startup regressions detected',
      );
    }

    if (verificationResult.hasMemoryRegression ||
        verificationResult.hasFTS5Regression ||
        verificationResult.isStorageCorrupt) {
      return const AcceptanceResult(
        outcome: GateOutcome.blocked,
        eligibility: PromotionEligibility.blocked,
        reason: 'Verification regressions detected',
      );
    }

    if (!startupContract.isOfflineSafe ||
        !startupContract.isStorageGuarded ||
        !startupContract.isLifecycleManaged) {
      return const AcceptanceResult(
        outcome: GateOutcome.failed,
        eligibility: PromotionEligibility.blocked,
        reason: 'Critical app readiness missing',
      );
    }

    for (final lang in languageEvidence) {
      if (!lang.hasLocalPackEvidence) {
        return const AcceptanceResult(
          outcome: GateOutcome.blocked,
          eligibility: PromotionEligibility.blocked,
          reason: 'Missing integrity evidence for a language',
        );
      }
      if (lang.isMetadataOnly) {
        return const AcceptanceResult(
          outcome: GateOutcome.blocked,
          eligibility: PromotionEligibility.blocked,
          reason: 'Unsupported language claims (metadata only)',
        );
      }
    }

    bool isDegraded = false;
    for (final opt in optionalFeatures) {
      if (!opt.isAvailable) {
        isDegraded = true;
      }
    }

    return AcceptanceResult(
      outcome: GateOutcome.passed,
      eligibility: isDegraded
          ? PromotionEligibility.degraded
          : PromotionEligibility.approved,
      reason:
          isDegraded ? 'Passed with degraded features' : 'All checks passed',
    );
  }

  @Deprecated('Use evaluateReadiness instead')
  PromotionEligibility evaluatePromotion({
    J025StartupContract? startupContract,
    J095VerificationResult? verificationResult,
    List<LanguageReadinessEvidence>? languageEvidence,
    List<OptionalFeatureEvidence>? optionalFeatures,
  }) {
    final result = evaluateReadiness(
      startupContract,
      verificationResult,
      languageEvidence ?? [],
      optionalFeatures ?? [],
    );
    return result.eligibility;
  }
}
