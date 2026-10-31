import 'package:deutsch_build/core/linguistics/irregular_verb_engine.dart';

void main() {
  final engine = IrregularVerbEngine();

  // 1. فحص الفعل المتعدي مع haben: sprechen -> sprach -> gesprochen (er spricht)
  final sprechen = engine.lookup('sprechen');
  assert(sprechen != null);
  assert(sprechen!.praeteritum == 'sprach');
  assert(sprechen!.partizip2 == 'gesprochen');
  assert(sprechen!.auxiliary == PerfectAuxiliary.haben);
  assert(sprechen!.present3rdPerson == 'spricht');

  // 2. فحص فعل الحركة مع sein: fahren -> fuhr -> gefahren (er fährt)
  final fahren = engine.lookup('fahren');
  assert(fahren != null);
  assert(fahren!.auxiliary == PerfectAuxiliary.sein);
  assert(fahren!.present3rdPerson == 'fährt');

  // 3. فحص صياغة جملة Perfekt: Er ist gefahren / Er hat gesprochen
  assert(engine.formPerfekt('fahren', 'Er') == 'Er ist gefahren');
  assert(engine.formPerfekt('sprechen', 'Er') == 'Er hat gesprochen');

  // 4. فحص فعل البقاء: bleiben -> ist geblieben
  assert(engine.formPerfekt('bleiben', 'Sie', isPlural: true) == 'Sie sind geblieben');

  print('Irregular verb engine unit assertions passed.');
}
