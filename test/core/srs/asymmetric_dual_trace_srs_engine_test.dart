import 'package:deutsch_build/core/srs/asymmetric_dual_trace_srs_engine.dart';

void main() {
  final engine = AsymmetricDualTraceSrsEngine();
  final initial = DualTraceMemoryState.initial();

  // 1. مراجعة إنتاج نشط ناجحة (Active Production): يجب أن ترفع المسارين معاً بقوة
  final stateAfterActive = engine.recordReview(
    current: initial,
    direction: ReviewDirection.activeProduction,
    success: true,
  );
  assert(stateAfterActive.activeStability >= 1.0);
  assert(stateAfterActive.passiveStability >= 1.5, 'Active success must cross-boost passive stability');

  // 2. مراجعة تعرف سلبي ناجحة (Passive Recognition): تعزيز الإنتاج يجب أن يكون محدوداً
  final stateAfterPassive = engine.recordReview(
    current: stateAfterActive,
    direction: ReviewDirection.passiveRecognition,
    success: true,
  );
  assert(stateAfterPassive.passiveStability > stateAfterActive.passiveStability);
  // تعزيز الإنتاج محدود بـ 15% فقط
  assert(stateAfterPassive.activeStability <= stateAfterActive.activeStability * 1.20);

  // 3. ترشيح الاتجاه: عند وجود فجوة لصالح التعرف، يجب ترشيح الإنتاج النشط
  final suggested = engine.suggestNextDirection(stateAfterPassive);
  assert(suggested == ReviewDirection.activeProduction);

  print('Asymmetric dual-trace SRS engine unit assertions passed.');
}
