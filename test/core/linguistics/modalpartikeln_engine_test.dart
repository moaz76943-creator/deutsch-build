import 'package:deutsch_build/core/linguistics/modalpartikeln_engine.dart';

void main() {
  final engine = ModalpartikelnEngine();

  // 1. اختبار استرجاع الشرح التداولي لأداة ja
  final expJa = engine.explain(Modalparticle.ja);
  assert(expJa != null);
  assert(expJa!.tone == PragmaticTone.sharedKnowledge);

  // 2. اختبار أداة denn في الأسئلة
  final expDenn = engine.explain(Modalparticle.denn);
  assert(expDenn != null);
  assert(expDenn!.tone == PragmaticTone.interestedInquiry);

  // 3. اختبار قيد الموقع الطوبولوجي (حظر Vorfeld: index = 0)
  assert(!engine.isValidPosition(0), 'Failed: particle erroneously allowed in Vorfeld');
  assert(engine.isValidPosition(2), 'Failed: particle rejected inside Mittelfeld');

  print('Modalpartikeln engine unit verification passed.');
}
