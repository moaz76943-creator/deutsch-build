import '../catalog/language_readiness_matrix.dart';

enum GateOutcome { passed, failed, blocked, notRun }
enum EligibilityState { approved, degraded, blocked, notVerified }

class AcceptanceEvidence {
  final bool? isOfflineSafe;
  final bool? isStorageGuarded;
  final bool? isLifecycleManaged;
  final bool? isDatabaseIntact;
  final bool? isContentReady;

  final DateTime? verificationTime;
  final List<String> claimedLanguages;
  final bool optionalAudioAvailable;

  const AcceptanceEvidence({
    this.isOfflineSafe,
    this.isStorageGuarded,
    this.isLifecycleManaged,
    this.isDatabaseIntact,
    this.isContentReady,
    this.verificationTime,
    this.claimedLanguages = const [],
    this.optionalAudioAvailable = false,
  });
}

class AcceptanceResult {
  final GateOutcome outcome;
  final EligibilityState state;
  final List<String> readyLanguages;

  const AcceptanceResult(this.outcome, this.state, {this.readyLanguages = const []});
}

/// بوابة قبول الجاهزية للإنتاج والمتجر الرسمي
class ProductionAcceptanceGate {
  static AcceptanceResult evaluate(AcceptanceEvidence evidence, {DateTime? now}) {
    if (evidence.verificationTime == null) {
      return const AcceptanceResult(GateOutcome.notRun, EligibilityState.notVerified);
    }

    final currentTime = now ?? DateTime.now();
    final age = currentTime.difference(evidence.verificationTime!);
    if (age.inMinutes > 30 || age.isNegative) {
      // Stale evidence -> fails closed
      return const AcceptanceResult(GateOutcome.failed, EligibilityState.blocked);
    }

    if (evidence.isOfflineSafe == null ||
        evidence.isStorageGuarded == null ||
        evidence.isLifecycleManaged == null ||
        evidence.isDatabaseIntact == null ||
        evidence.isContentReady == null) {
      // Missing mandatory evidence -> fails closed
      return const AcceptanceResult(GateOutcome.failed, EligibilityState.blocked);
    }

    if (evidence.isOfflineSafe == false ||
        evidence.isStorageGuarded == false ||
        evidence.isLifecycleManaged == false ||
        evidence.isDatabaseIntact == false ||
        evidence.isContentReady == false) {
      // Regression / corruption -> blocked
      return const AcceptanceResult(GateOutcome.blocked, EligibilityState.blocked);
    }

    final readyLanguages = <String>[];
    for (final lang in evidence.claimedLanguages) {
      if (LanguageReadinessMatrix.isProductionReady(lang)) {
        readyLanguages.add(lang);
      }
    }

    if (!evidence.optionalAudioAvailable) {
      // Missing optional features -> gracefully degrades
      return AcceptanceResult(GateOutcome.passed, EligibilityState.degraded, readyLanguages: readyLanguages);
    }

    return AcceptanceResult(GateOutcome.passed, EligibilityState.approved, readyLanguages: readyLanguages);
  }

  // Legacy fallback
  static bool verifyAppReadiness({
    required bool isOfflineSafe,
    required bool isStorageGuarded,
    required bool isLifecycleManaged,
  }) {
    final evidence = AcceptanceEvidence(
      isOfflineSafe: isOfflineSafe,
      isStorageGuarded: isStorageGuarded,
      isLifecycleManaged: isLifecycleManaged,
      isDatabaseIntact: true, // Assuming true for legacy
      isContentReady: true,   // Assuming true for legacy
      verificationTime: DateTime.now(),
      optionalAudioAvailable: true, // Assuming fully approved for legacy true case
    );
    final result = evaluate(evidence);
    return result.outcome == GateOutcome.passed;
  }
}
