import '../catalog/language_readiness_matrix.dart';

enum EligibilityState { approved, degraded, blocked, notVerified }

class AcceptanceEvidence {
  final bool isOfflineSafe;
  final bool isStorageGuarded;
  final bool isLifecycleManaged;
  final bool hasJ025Contract;
  final bool hasJ095Contract;
  final bool hasNewDartErrors;
  final bool hasMemoryRegression;
  final bool hasFTS5Regression;
  final bool verifiedNormalStartup;
  final bool verifiedSafeModeStartup;
  final bool isEvidenceStale;
  final bool isMissingMandatoryEvidence;
  final bool isOptionalTtsAvailable;
  final List<String> verifiedLocalLanguagePacks;
  final List<String> metadataOnlyLanguages;

  const AcceptanceEvidence({
    required this.isOfflineSafe,
    required this.isStorageGuarded,
    required this.isLifecycleManaged,
    required this.hasJ025Contract,
    required this.hasJ095Contract,
    required this.hasNewDartErrors,
    required this.hasMemoryRegression,
    required this.hasFTS5Regression,
    required this.verifiedNormalStartup,
    required this.verifiedSafeModeStartup,
    required this.isEvidenceStale,
    required this.isMissingMandatoryEvidence,
    required this.isOptionalTtsAvailable,
    required this.verifiedLocalLanguagePacks,
    required this.metadataOnlyLanguages,
  });
}

/// بوابة قبول الجاهزية للإنتاج والمتجر الرسمي
class ProductionAcceptanceGate {
  static AcceptanceEvidence? _lastApprovedEvidence;

  static AcceptanceEvidence? get lastApprovedConfiguration => _lastApprovedEvidence;

  static bool verifyAppReadiness({
    required bool isOfflineSafe,
    required bool isStorageGuarded,
    required bool isLifecycleManaged,
  }) {
    return isOfflineSafe && isStorageGuarded && isLifecycleManaged;
  }

  static EligibilityState evaluateEligibility(AcceptanceEvidence? evidence) {
    if (evidence == null || evidence.isMissingMandatoryEvidence || evidence.isEvidenceStale) {
      return EligibilityState.notVerified;
    }

    if (!evidence.hasJ025Contract || !evidence.hasJ095Contract) {
      return EligibilityState.notVerified;
    }

    if (!evidence.isOfflineSafe ||
        !evidence.isStorageGuarded ||
        !evidence.isLifecycleManaged ||
        evidence.hasNewDartErrors ||
        evidence.hasMemoryRegression ||
        evidence.hasFTS5Regression ||
        !evidence.verifiedNormalStartup ||
        !evidence.verifiedSafeModeStartup) {
      return EligibilityState.blocked;
    }

    for (final lang in evidence.verifiedLocalLanguagePacks) {
      if (LanguageReadinessMatrix.getTier(lang) != LanguageReadinessTier.productionReady) {
        return EligibilityState.blocked;
      }
    }

    if (evidence.metadataOnlyLanguages.isNotEmpty) {
      return EligibilityState.blocked;
    }

    if (!evidence.isOptionalTtsAvailable) {
      _lastApprovedEvidence = evidence;
      return EligibilityState.degraded;
    }

    _lastApprovedEvidence = evidence;
    return EligibilityState.approved;
  }
}
