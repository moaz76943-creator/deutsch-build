import 'package:deutsch_build/core/linguistics/prefix_verb_engine.dart';

void main() {
  final engine = PrefixVerbEngine();

  // 1. فحص الفعل المنفصل: aufstehen -> auf (separable)
  final resAuf = engine.analyze('aufstehen');
  assert(resAuf.category == PrefixCategory.separable);
  assert(resAuf.isSeparatedInMainClause);
  assert(resAuf.prefix == 'auf');
  assert(resAuf.zuInfinitivExample.contains('aufzustehen'));

  // 2. فحص الفعل غير المنفصل: verstehen -> ver (inseparable)
  final resVer = engine.analyze('verstehen');
  assert(resVer.category == PrefixCategory.inseparable);
  assert(!resVer.isSeparatedInMainClause);
  assert(resVer.prefix == 'ver');
  assert(resVer.zuInfinitivExample == 'zu verstehen');

  // 3. فحص مشبك الجملة (انفصال البادئة لآخر الجملة): Ich stehe um 7 Uhr auf.
  final sentence = engine.constructMainClausePresent(
    subject: 'Ich',
    verb: 'aufstehen',
    conjugatedStem: 'stehe',
    mittelfeldObjects: 'um 7 Uhr',
  );
  assert(sentence == 'Ich stehe um 7 Uhr auf.');

  print('Prefix verbs engine unit assertions passed.');
}
