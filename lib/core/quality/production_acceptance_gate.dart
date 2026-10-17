import '../catalog/language_readiness_matrix.dart';

enum GateOutcome { PASSED, FAILED, BLOCKED, NOT_RUN }

class AcceptanceResult {
  final GateOutcome outcome;
  final String reason;
  final List<String> verifiedLanguages;
  final bool isAudioAvailable;

  const AcceptanceResult({
    required this.outcome,
    required this.reason,
    required this.verifiedLanguages,
    required this.isAudioAvailable,
  });
}

class AcceptanceEvidence {
  final bool isOfflineSafe;
  final bool isStorageGuarded;
  final bool isLifecycleManaged;
  final bool hasStorageCorruption;
  final bool hasStartupRecoveryFailed;
  final DateTime? verificationTimestamp;
  final List<String> declaredLanguages;
  final bool isAudioAvailable;

  const AcceptanceEvidence({
    required this.isOfflineSafe,
    required this.isStorageGuarded,
    required this.isLifecycleManaged,
    this.hasStorageCorruption = false,
    this.hasStartupRecoveryFailed = false,
    this.verificationTimestamp,
    this.declaredLanguages = const [],
    this.isAudioAvailable = false,
  });
}

/// بوابة قبول الجاهزية للإنتاج والمتجر الرسمي
class ProductionAcceptanceGate {
  static AcceptanceResult evaluateReadiness(AcceptanceEvidence evidence) {
    if (evidence.verificationTimestamp == null) {
      return const AcceptanceResult(
        outcome: GateOutcome.NOT_RUN,
        reason: 'Verification timestamp is missing.',
        verifiedLanguages: [],
        isAudioAvailable: false,
      );
    }

    if (evidence.hasStorageCorruption) {
      return AcceptanceResult(
        outcome: GateOutcome.BLOCKED,
        reason: 'Storage corruption detected.',
        verifiedLanguages: [],
        isAudioAvailable: evidence.isAudioAvailable,
      );
    }

    if (evidence.hasStartupRecoveryFailed) {
      return AcceptanceResult(
        outcome: GateOutcome.BLOCKED,
        reason: 'Startup recovery failed.',
        verifiedLanguages: [],
        isAudioAvailable: evidence.isAudioAvailable,
      );
    }

    if (!evidence.isOfflineSafe) {
      return AcceptanceResult(
        outcome: GateOutcome.FAILED,
        reason: 'Missing offline safety evidence.',
        verifiedLanguages: [],
        isAudioAvailable: evidence.isAudioAvailable,
      );
    }

    if (!evidence.isStorageGuarded) {
      return AcceptanceResult(
        outcome: GateOutcome.FAILED,
        reason: 'Missing storage guard evidence.',
        verifiedLanguages: [],
        isAudioAvailable: evidence.isAudioAvailable,
      );
    }

    if (!evidence.isLifecycleManaged) {
      return AcceptanceResult(
        outcome: GateOutcome.FAILED,
        reason: 'Missing lifecycle managed evidence.',
        verifiedLanguages: [],
        isAudioAvailable: evidence.isAudioAvailable,
      );
    }

    final now = DateTime.now();
    if (now.difference(evidence.verificationTimestamp!).inHours > 1) {
      return AcceptanceResult(
        outcome: GateOutcome.FAILED,
        reason: 'Stale verification results.',
        verifiedLanguages: [],
        isAudioAvailable: evidence.isAudioAvailable,
      );
    }

    final verifiedLangs = <String>[];
    for (final lang in evidence.declaredLanguages) {
      if (!LanguageReadinessMatrix.isProductionReady(lang)) {
        return AcceptanceResult(
          outcome: GateOutcome.FAILED,
          reason: 'Unverified dictionary claim for language: $lang.',
          verifiedLanguages: verifiedLangs,
          isAudioAvailable: evidence.isAudioAvailable,
        );
      }
      verifiedLangs.add(lang);
    }

    return AcceptanceResult(
      outcome: GateOutcome.PASSED,
      reason: 'All mandatory and declared evidence passed.',
      verifiedLanguages: verifiedLangs,
      isAudioAvailable: evidence.isAudioAvailable,
    );
  }

  static bool verifyAppReadiness({
    required bool isOfflineSafe,
    required bool isStorageGuarded,
    required bool isLifecycleManaged,
  }) {
    final evidence = AcceptanceEvidence(
      isOfflineSafe: isOfflineSafe,
      isStorageGuarded: isStorageGuarded,
      isLifecycleManaged: isLifecycleManaged,
      verificationTimestamp: DateTime.now(),
    );
    final result = evaluateReadiness(evidence);
    return result.outcome == GateOutcome.PASSED;
  }
}
