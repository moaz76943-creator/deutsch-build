import 'package:deutsch_build/core/linguistics/fvg_engine.dart';

void main() {
  final engine = FunktionsverbgefuegeEngine();

  // 1. اختبار التحويل من الفعل البسيط إلى FVG: entscheiden -> eine Entscheidung treffen
  final fvgEntscheiden = engine.findBySimpleVerb('entscheiden');
  assert(fvgEntscheiden != null);
  assert(fvgEntscheiden!.functionVerb == 'treffen');
  assert(fvgEntscheiden!.nounPhrase == 'eine Entscheidung');

  // 2. اختبار التحقق من المتلازمة الصحيحة: zur Verfügung stehen
  assert(engine.validateCollocation('Verfügung', 'stehen', prep: 'zur'));

  // 3. رفض المتلازمة الخاطئة (مثال: استخدام machen بدل treffen)
  assert(!engine.validateCollocation('Entscheidung', 'machen'));

  print('FVG engine unit verification passed.');
}
