enum PromotionEligibility { approved, degraded, blocked, notVerified }

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

/// بوابة قبول الجاهزية للإنتاج والمتجر الرسمي
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

  static PromotionEligibility evaluatePromotion({
    required bool isOfflineSafe,
    required bool isStorageGuarded,
    required bool isLifecycleManaged,
    required J095VerificationContract? j095contract,
    required List<J025LanguageContract> languages,
    required OptionalFeatureContract optionalFeatures,
  }) {
    if (j095contract == null ||
        !j095contract.hasMandatoryEvidence ||
        j095contract.hasStaleEvidence) {
      return PromotionEligibility.notVerified;
    }

    if (!verifyAppReadiness(
      isOfflineSafe: isOfflineSafe,
      isStorageGuarded: isStorageGuarded,
      isLifecycleManaged: isLifecycleManaged,
    )) {
      return PromotionEligibility.blocked;
    }

    if (j095contract.hasNewDartErrors ||
        j095contract.hasMemoryRegression ||
        j095contract.hasFTS5Regression ||
        j095contract.hasCorruptStorage ||
        !j095contract.isNormalStartupVerified ||
        !j095contract.isSafeModeBehaviorVerified) {
      return PromotionEligibility.blocked;
    }

    for (var lang in languages) {
      if (!lang.hasLocalPackEvidence || lang.isMetadataOnly) {
        return PromotionEligibility.blocked;
      }
    }

    _lastApprovedConfiguration = ApprovedFeatureConfiguration(
      isOfflineSafe: isOfflineSafe,
      isStorageGuarded: isStorageGuarded,
      isLifecycleManaged: isLifecycleManaged,
      approvalTime: DateTime.now(),
    );

    if (!optionalFeatures.isTtsAvailable) {
      return PromotionEligibility.degraded;
    }

    return PromotionEligibility.approved;
  }

  // For testing purposes
  static void resetState() {
    _lastApprovedConfiguration = null;
  }
}
