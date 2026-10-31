import 'package:deutsch_build/core/linguistics/participial_attribute_engine.dart';

void main() {
  final engine = ParticipialAttributeEngine();

  // 1. فحص اشتقاق Partizip I: spielen -> spielende
  final p1 = engine.formPartizip1('spielen', adjectiveEnding: 'e');
  assert(p1 == 'spielende');

  // 2. فحص صيغة Gerundivum: lösen -> zu lösende
  final gerund = engine.formGerundivum('lösen', adjectiveEnding: 'e');
  assert(gerund == 'zu lösende');

  // 3. فحص التحويل التبادلي لاسم الفاعل
  final resActive = engine.resolveAttribute(
    baseVerb: 'arbeite',
    noun: 'Mann',
    type: ParticipleType.partizip1Active,
    modifier: 'im Garten',
  );
  assert(resActive.participialAttribute.contains('im Garten arbeitende Mann'));

  // 4. فحص دلالة صيغة الوجوب
  final resGerund = engine.resolveAttribute(
    baseVerb: 'lös',
    noun: 'Problem',
    type: ParticipleType.gerundivumObligatory,
  );
  assert(resGerund.equivalentRelativeClause.contains('werden muss / kann'));

  print('Participial attribute engine unit assertions passed.');
}
