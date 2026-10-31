import 'fsrs5_scheduler_engine.dart';
import 'leech_rif_quarantine_engine.dart';
import 'cognitive_interleaving_engine.dart';
import 'interval_fuzzing_engine.dart';
import 'asymmetric_dual_trace_srs_engine.dart';
import 'bayesian_knowledge_tracing_engine.dart';

class AdaptiveReviewResult {
  final SrsScheduleOutcome fsrsOutcome;
  final int finalFuzzedInterval;
  final DualTraceMemoryState dualTraceState;
  final BktUpdateOutcome bktOutcome;
  final LeechDiagnosis leechDiagnosis;

  const AdaptiveReviewResult({
    required this.fsrsOutcome,
    required this.finalFuzzedInterval,
    required this.dualTraceState,
    required this.bktOutcome,
    required this.leechDiagnosis,
  });
}

/// Master Unified Facade governing all 6 cognitive and spaced repetition engines.
/// Adheres strictly to Chapter 8.3: isolated execution, zero lock contention, deterministic fuzzing.
class AdaptiveLearningCoordinator {
  final Fsrs5SchedulerEngine fsrs = const Fsrs5SchedulerEngine(requestRetention: 0.90);
  final LeechAndRifQuarantineEngine leechRif = LeechAndRifQuarantineEngine();
  final CognitiveInterleavingEngine interleaving = const CognitiveInterleavingEngine(maxConsecutiveModality: 2);
  final IntervalFuzzingEngine fuzzing = IntervalFuzzingEngine();
  final AsymmetricDualTraceSrsEngine dualTrace = AsymmetricDualTraceSrsEngine();
  final BayesianKnowledgeTracingEngine bkt = const BayesianKnowledgeTracingEngine(masteryThreshold: 0.95);

  /// معالجة مراجعة البطاقة وتحديث مسارات الذاكرة المعرفية كاملة في خطوة ذرية واحدة
  AdaptiveReviewResult processReview({
    required String cardId,
    required SrsCardState currentState,
    required DualTraceMemoryState currentDualTrace,
    required double currentBktMastery,
    required SrsRating rating,
    required ReviewDirection direction,
    required String semanticCategory,
    required DateTime reviewTime,
  }) {
    final isSuccess = rating != SrsRating.again;

    // 1. حساب جدولة FSRS-5 DSR
    final fsrsOutcome = fsrs.evaluateReview(
      current: currentState,
      rating: rating,
      reviewTime: reviewTime,
    );

    // 2. تطبيق تشتيت الفترات لمنع تكدس المراجعات مستقبلاً
    final fuzzedInterval = fuzzing.applyFuzz(
      rawIntervalDays: fsrsOutcome.nextIntervalDays,
      cardId: cardId,
    );

    // 3. تحديث مسار الأثر المزدوج اللامتناظر (Passive vs Active)
    final updatedDualTrace = dualTrace.recordReview(
      current: currentDualTrace,
      direction: direction,
      success: isSuccess,
    );

    // 4. تحديث احتمالية إتقان المهارة عبر التتبع البايزي (BKT)
    final bktOutcome = bkt.updateKnowledge(
      priorMastery: currentBktMastery,
      isCorrect: isSuccess,
    );

    // 5. فحص وتشخيص البطاقات العالقة (Leech Detection)
    final leechDiagnosis = leechRif.evaluateLeech(cardId, fsrsOutcome.updatedState.lapses);

    // 6. حجر الفئة الدلالية لمنع التثبيط التنافسي (RIF Quarantine)
    leechRif.registerCategoryReview(semanticCategory);

    return AdaptiveReviewResult(
      fsrsOutcome: fsrsOutcome,
      finalFuzzedInterval: fuzzedInterval,
      dualTraceState: updatedDualTrace,
      bktOutcome: bktOutcome,
      leechDiagnosis: leechDiagnosis,
    );
  }

  /// إعداد طابور مراجعات الجلسة اليومية بتطبيق التوزيع التبادلي لكسر الرتابة
  List<InterleavedReviewItem> prepareSessionQueue(List<InterleavedReviewItem> candidateItems) {
    return interleaving.interleave(candidateItems);
  }
}
