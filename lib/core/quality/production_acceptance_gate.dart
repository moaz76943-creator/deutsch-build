import '../catalog/language_readiness_matrix.dart';

enum GateOutcome { passed, failed, blocked, notRun }
enum EligibilityState { approved, degraded, blocked, notVerified }

class AcceptanceEvidence {
  final bool isOfflineSafe;
  final bool isStorageGuarded;
  final bool isLifecycleManaged;
  final bool hasCorruptedContent;
  final bool hasRegressions;
  final bool isStale;
  final bool missingOptionalFeatures;
  final List<String> verifiedLanguages;

  const AcceptanceEvidence({
    required this.isOfflineSafe,
    required this.isStorageGuarded,
    required this.isLifecycleManaged,
    this.hasCorruptedContent = false,
    this.hasRegressions = false,
    this.isStale = false,
    this.missingOptionalFeatures = false,
    this.verifiedLanguages = const [],
  });
}

class AcceptanceResult {
  final GateOutcome outcome;
  final EligibilityState state;
  final String reason;

  const AcceptanceResult({
    required this.outcome,
    required this.state,
    required this.reason,
  });

  bool get isReady => outcome == GateOutcome.passed;
}

/// بوابة قبول الجاهزية للإنتاج والمتجر الرسمي
class ProductionAcceptanceGate {
  static AcceptanceResult evaluateEvidence(AcceptanceEvidence? evidence) {
    if (evidence == null) {
      return const AcceptanceResult(
        outcome: GateOutcome.notRun,
        state: EligibilityState.notVerified,
        reason: 'Missing evidence.',
      );
    }

    if (evidence.isStale) {
      return const AcceptanceResult(
        outcome: GateOutcome.notRun,
        state: EligibilityState.notVerified,
        reason: 'Stale evidence.',
      );
    }

    if (evidence.hasCorruptedContent) {
      return const AcceptanceResult(
        outcome: GateOutcome.blocked,
        state: EligibilityState.blocked,
        reason: 'Corrupted content detected.',
      );
    }

    if (evidence.hasRegressions) {
      return const AcceptanceResult(
        outcome: GateOutcome.blocked,
        state: EligibilityState.blocked,
        reason: 'Regressions detected.',
      );
    }

    if (!evidence.isOfflineSafe || !evidence.isStorageGuarded || !evidence.isLifecycleManaged) {
      return const AcceptanceResult(
        outcome: GateOutcome.failed,
        state: EligibilityState.blocked,
        reason: 'Missing critical infrastructure readiness.',
      );
    }

    for (final lang in evidence.verifiedLanguages) {
      if (!LanguageReadinessMatrix.isProductionReady(lang)) {
        return AcceptanceResult(
          outcome: GateOutcome.failed,
          state: EligibilityState.blocked,
          reason: 'Language not production ready: $lang.',
        );
      }
    }

    if (evidence.missingOptionalFeatures) {
      return const AcceptanceResult(
        outcome: GateOutcome.passed,
        state: EligibilityState.degraded,
        reason: 'Passed with degraded features.',
      );
    }

    return const AcceptanceResult(
      outcome: GateOutcome.passed,
      state: EligibilityState.approved,
      reason: 'Fully approved.',
    );
  }

  static bool verifyAppReadiness({
    required bool isOfflineSafe,
    required bool isStorageGuarded,
    required bool isLifecycleManaged,
  }) {
    final result = evaluateEvidence(AcceptanceEvidence(
      isOfflineSafe: isOfflineSafe,
      isStorageGuarded: isStorageGuarded,
      isLifecycleManaged: isLifecycleManaged,
    ));
    return result.isReady;
  }
}
