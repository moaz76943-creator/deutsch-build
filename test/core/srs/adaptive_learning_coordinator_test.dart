import 'package:deutsch_build/core/srs/adaptive_learning_coordinator.dart';
import 'package:deutsch_build/core/srs/fsrs5_scheduler_engine.dart';
import 'package:deutsch_build/core/srs/asymmetric_dual_trace_srs_engine.dart';

void main() {
  final coordinator = AdaptiveLearningCoordinator();

  // فحص معالجة دورة مراجعة متكاملة للبطاقة
  final card = SrsCardState.initial();
  final dualState = DualTraceMemoryState.initial();

  final result = coordinator.processReview(
    cardId: 'card_verb_lernen',
    currentState: card,
    currentDualTrace: dualState,
    currentBktMastery: 0.20,
    rating: SrsRating.good,
    direction: ReviewDirection.activeProduction,
    semanticCategory: 'education_verbs',
    reviewTime: DateTime.now(),
  );

  // 1. التحقق من سلامة FSRS-5 والفاصل الزمني المشتت
  assert(result.fsrsOutcome.updatedState.reps == 1);
  assert(result.finalFuzzedInterval >= 1);

  // 2. التحقق من اقتران الأثر المزدوج (نجاح الإنتاج رفع التعرف السلبي تلقائياً)
  assert(result.dualTraceState.activeStability >= 1.0);
  assert(result.dualTraceState.passiveStability >= 1.5);

  // 3. التحقق من التحديث البايزي للإتقان
  assert(result.bktOutcome.posteriorMastery > 0.40);

  // 4. التحقق من حجر الفئة الدلالية RIF لمنع المنافسين المباشرين
  assert(coordinator.leechRif.isCategoryQuarantined('education_verbs'));

  print('Master Adaptive Learning Coordinator unit assertions passed.');
}
