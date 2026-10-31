import 'package:deutsch_build/core/linguistics/epistemic_modal_engine.dart';

void main() {
  final engine = EpistemicModalEngine();

  // 1. فحص درجات اليقين الرياضية: müssen (95%) و dürfte (75%)
  final pMussen = engine.getProfile('müssen');
  assert(pMussen != null && pMussen.confidencePercent == 95);

  final pDurfte = engine.getProfile('dürfte');
  assert(pDurfte != null && pDurfte.confidencePercent == 75);

  // 2. فحص صياغة الماضي التخميني: Er muss den Zug verpasst haben
  final pastInference = engine.constructPastInference(
    subject: 'Er',
    modalPresent: 'muss',
    partizipIi: 'den Zug verpasst',
    auxInfinitiv: 'haben',
  );
  assert(pastInference == 'Er muss den Zug verpasst haben');

  // 3. كشف الخطأ الشائع (استخدام musste بدل muss ... haben)
  assert(engine.isErroneousPastEpistemicForm('musste'), 'Failed to flag "musste" as non-epistemic past');
  assert(!engine.isErroneousPastEpistemicForm('muss'), 'Falsely flagged valid present modal');

  print('Epistemic modal engine unit assertions passed.');
}
