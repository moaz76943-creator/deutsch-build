import 'package:deutsch_build/core/linguistics/konjunktiv_ii_engine.dart';

void main() {
  final engine = KonjunktivIiEngine();

  // 1. فحص الجذور التركيبية المباشرة (sein -> ich wäre, erSieEs wäre)
  assert(engine.conjugatePresent('sein', GrammaticalPerson.ich) == 'wäre');
  assert(engine.conjugatePresent('haben', GrammaticalPerson.du) == 'hättest');
  assert(engine.conjugatePresent('können', GrammaticalPerson.erSieEs) == 'könnte');

  // 2. فحص الصياغة التحليلية لبقية الأفعال: lernen -> wir würden lernen
  assert(engine.conjugatePresent('lernen', GrammaticalPerson.wir) == 'würden lernen');

  // 3. فحص شرط الماضي غير المتحقق: hätte gemacht / wäre gekommen
  assert(engine.conjugatePast(
    person: GrammaticalPerson.ich,
    auxiliary: 'haben',
    partizipIi: 'gemacht',
  ) == 'hätte gemacht');

  assert(engine.conjugatePast(
    person: GrammaticalPerson.erSieEs,
    auxiliary: 'sein',
    partizipIi: 'gekommen',
  ) == 'wäre gekommen');

  // 4. فحص الطلب المهذب
  final request = engine.generatePoliteRequest('helfen');
  assert(request.contains('Könnten Sie bitte helfen?'));

  print('Konjunktiv II engine unit verification passed.');
}
