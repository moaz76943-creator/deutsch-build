import '../catalog/language_readiness_matrix.dart';

enum GateOutcome { passed, failed, blocked, notRun }

enum EligibilityState { approved, degraded, blocked, notVerified }

class AcceptanceEvidence {
  final bool hasJ025Contract;
  final bool hasJ095Contract;
  final bool dartErrorsDetected;
  final bool memoryRegressionConfirmed;
  final bool fts5RegressionConfirmed;
  final bool normalStartupVerified;
  final bool safeModeVerified;
  final bool isOfflineSafe;
  final bool isStorageGuarded;
  final bool isLifecycleManaged;
  final bool optionalTtsAvailable;
  final bool isStale;
  final String? languageCode;

  const AcceptanceEvidence({
    required this.hasJ025Contract,
    required this.hasJ095Contract,
    required this.dartErrorsDetected,
    required this.memoryRegressionConfirmed,
    required this.fts5RegressionConfirmed,
    required this.normalStartupVerified,
    required this.safeModeVerified,
    required this.isOfflineSafe,
    required this.isStorageGuarded,
    required this.isLifecycleManaged,
    this.optionalTtsAvailable = false,
    this.isStale = false,
    this.languageCode,
  });
}

class AcceptanceResult {
  final GateOutcome outcome;
  final EligibilityState state;

  const AcceptanceResult(this.outcome, this.state);
}

/// بوابة قبول الجاهزية للإنتاج والمتجر الرسمي
class ProductionAcceptanceGate {
  static AcceptanceEvidence? _lastApprovedFeatureConfiguration;

  static AcceptanceEvidence? get lastApprovedFeatureConfiguration => _lastApprovedFeatureConfiguration;

  static AcceptanceResult evaluate(AcceptanceEvidence evidence) {
    if (evidence.isStale) {
      return const AcceptanceResult(GateOutcome.failed, EligibilityState.notVerified);
    }

    if (!evidence.hasJ025Contract || !evidence.hasJ095Contract) {
      return const AcceptanceResult(GateOutcome.failed, EligibilityState.notVerified);
    }

    if (!evidence.normalStartupVerified || !evidence.safeModeVerified) {
      return const AcceptanceResult(GateOutcome.failed, EligibilityState.notVerified);
    }

    if (evidence.dartErrorsDetected || evidence.memoryRegressionConfirmed || evidence.fts5RegressionConfirmed) {
      return const AcceptanceResult(GateOutcome.blocked, EligibilityState.blocked);
    }

    if (!evidence.isOfflineSafe || !evidence.isStorageGuarded || !evidence.isLifecycleManaged) {
      return const AcceptanceResult(GateOutcome.failed, EligibilityState.notVerified);
    }

    if (evidence.languageCode != null) {
      if (!LanguageReadinessMatrix.isProductionReady(evidence.languageCode!)) {
         return const AcceptanceResult(GateOutcome.failed, EligibilityState.notVerified);
      }
    }

    if (!evidence.optionalTtsAvailable) {
       _lastApprovedFeatureConfiguration = evidence;
      return const AcceptanceResult(GateOutcome.passed, EligibilityState.degraded);
    }

    _lastApprovedFeatureConfiguration = evidence;
    return const AcceptanceResult(GateOutcome.passed, EligibilityState.approved);
  }

  static bool verifyAppReadiness({
    required bool isOfflineSafe,
    required bool isStorageGuarded,
    required bool isLifecycleManaged,
  }) {
    return isOfflineSafe && isStorageGuarded && isLifecycleManaged;
  }
}
