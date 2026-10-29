enum GateOutcome {
  passed,
  failed,
  blocked,
  notRun,
}

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
  bool get hasLocalPackEvidence;
  bool get isMetadataOnly;
}

abstract class OptionalFeatureContract {
  bool get isTtsAvailable;
}

/// بوابة قبول الجاهزية للإنتاج والمتجر الرسمي
enum PromotionEligibility { approved, degraded, blocked, notVerified }

class ProductionAcceptanceGate {
  static ApprovedFeatureConfiguration? _lastApprovedConfiguration;
  static ApprovedFeatureConfiguration? get lastApprovedConfiguration =>
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
}
