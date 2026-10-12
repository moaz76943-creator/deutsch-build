enum PromotionEligibility { approved, degraded, blocked, notVerified }

class ProductionEvidence {
  final bool? isJ025ContractVerified;
  final bool? isJ095ContractVerified;
  final bool? hasDartErrors;
  final bool? hasMemoryRegression;
  final bool? hasFTS5Regression;
  final bool? isNormalStartupVerified;
  final bool? isSafeModeVerified;
  final bool? isStorageCorrupt;
  final bool? isOptionalTTSAvailable;
  final bool? isLanguagePackLocalEvidenceAvailable;
  final bool? isMetadataOnlyLanguage;
  final DateTime timestamp;

  const ProductionEvidence({
    this.isJ025ContractVerified,
    this.isJ095ContractVerified,
    this.hasDartErrors,
    this.hasMemoryRegression,
    this.hasFTS5Regression,
    this.isNormalStartupVerified,
    this.isSafeModeVerified,
    this.isStorageCorrupt,
    this.isOptionalTTSAvailable,
    this.isLanguagePackLocalEvidenceAvailable,
    this.isMetadataOnlyLanguage,
    required this.timestamp,
  });

  bool get isStale => DateTime.now().toUtc().difference(timestamp.toUtc()).inMinutes > 5;
}

/// بوابة قبول الجاهزية للإنتاج والمتجر الرسمي
class ProductionAcceptanceGate {
  static ProductionEvidence? _lastApprovedEvidence;

  static ProductionEvidence? get lastApprovedEvidence => _lastApprovedEvidence;

  static PromotionEligibility evaluatePromotionEligibility(ProductionEvidence? evidence) {
    if (evidence == null || evidence.isStale) {
      return PromotionEligibility.notVerified;
    }

    // Treat missing mandatory evidence as notVerified.
    if (evidence.isJ025ContractVerified == null ||
        evidence.isJ095ContractVerified == null ||
        evidence.isNormalStartupVerified == null ||
        evidence.isSafeModeVerified == null ||
        evidence.isLanguagePackLocalEvidenceAvailable == null ||
        evidence.hasDartErrors == null ||
        evidence.hasMemoryRegression == null ||
        evidence.hasFTS5Regression == null ||
        evidence.isStorageCorrupt == null ||
        evidence.isMetadataOnlyLanguage == null) {
      return PromotionEligibility.notVerified;
    }

    if (evidence.isJ025ContractVerified == false || evidence.isJ095ContractVerified == false) {
      return PromotionEligibility.notVerified;
    }

    // Critical integrity or security decisions that block promotion
    if (evidence.hasDartErrors == true ||
        evidence.hasMemoryRegression == true ||
        evidence.hasFTS5Regression == true ||
        evidence.isStorageCorrupt == true ||
        evidence.isNormalStartupVerified == false ||
        evidence.isSafeModeVerified == false ||
        evidence.isMetadataOnlyLanguage == true ||
        evidence.isLanguagePackLocalEvidenceAvailable == false) {
      return PromotionEligibility.blocked;
    }

    // Optional features like TTS can degrade the readiness but not block it
    if (evidence.isOptionalTTSAvailable == false || evidence.isOptionalTTSAvailable == null) {
      _lastApprovedEvidence = evidence;
      return PromotionEligibility.degraded;
    }

    _lastApprovedEvidence = evidence;
    return PromotionEligibility.approved;
  }

  static bool verifyAppReadiness({
    required bool isOfflineSafe,
    required bool isStorageGuarded,
    required bool isLifecycleManaged,
  }) {
    return isOfflineSafe && isStorageGuarded && isLifecycleManaged;
  }
}
