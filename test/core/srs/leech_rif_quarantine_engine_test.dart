import 'package:deutsch_build/core/srs/leech_rif_quarantine_engine.dart';

void main() {
  final engine = LeechAndRifQuarantineEngine(lapseThreshold: 4, quarantineWindowSize: 3);

  // 1. فحص تشخيص البطاقة العالقة (lapses = 4)
  final diagLeech = engine.evaluateLeech('card_101', 4);
  assert(diagLeech.state == LeechState.quarantinedLeech);
  assert(diagLeech.recommendedStrategy == RemediationStrategy.morphologicalDecomposition);

  // 2. فحص حالة التحذير (lapses = 3)
  final diagWarning = engine.evaluateLeech('card_102', 3);
  assert(diagWarning.state == LeechState.warning);

  // 3. فحص الحالة الطبيعية (lapses = 1)
  final diagNormal = engine.evaluateLeech('card_103', 1);
  assert(diagNormal.state == LeechState.normal);

  // 4. فحص نافذة الحجر الدلالي RIF: عند مراجعة فئة 'fruits'، يجب حجر المتنافسين فيها
  assert(!engine.isCategoryQuarantined('fruits'));
  engine.registerCategoryReview('fruits');
  assert(engine.isCategoryQuarantined('fruits'), 'Failed: Category should be quarantined');

  // بعد مرور 3 بطاقات من فئات أخرى تنتهي نافذة الحجر
  engine.registerCategoryReview('animals');
  engine.registerCategoryReview('clothing');
  engine.registerCategoryReview('furniture');
  assert(!engine.isCategoryQuarantined('fruits'), 'Failed: Quarantine window did not expire');

  print('Leech and RIF quarantine engine assertions passed.');
}
