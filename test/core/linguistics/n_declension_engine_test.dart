import 'package:deutsch_build/core/linguistics/n_declension_engine.dart';

void main() {
  final engine = NDeklinationEngine();

  // 1. Student (ينتهي بـ -ent -> Studenten في النصب والجر والإضافة)
  assert(engine.inflectSingular('Student', GrammaticalCase.nominative) == 'Student');
  assert(engine.inflectSingular('Student', GrammaticalCase.accusative) == 'Studenten');
  assert(engine.inflectSingular('Student', GrammaticalCase.dative) == 'Studenten');
  assert(engine.inflectSingular('Student', GrammaticalCase.genitive) == 'Studenten');

  // 2. Junge (ينتهي بـ -e -> Jungen في النصب والجر)
  assert(engine.inflectSingular('Junge', GrammaticalCase.accusative) == 'Jungen');

  // 3. Name (استثناء -ns في الإضافة)
  assert(engine.inflectSingular('Name', GrammaticalCase.genitive) == 'Namens');
  assert(engine.inflectSingular('Name', GrammaticalCase.dative) == 'Namen');

  // 4. das Herz (استثناء محايد)
  assert(engine.inflectSingular('Herz', GrammaticalCase.nominative) == 'Herz');
  assert(engine.inflectSingular('Herz', GrammaticalCase.accusative) == 'Herz');
  assert(engine.inflectSingular('Herz', GrammaticalCase.genitive) == 'Herzens');

  // 5. التحقق من كشف الأخطاء
  final errorMsg = engine.validateLearnerUsage('Student', GrammaticalCase.accusative, 'Student');
  assert(errorMsg != null, 'Failed to catch missing -en on Student');

  print('N-Deklination engine unit assertions passed.');
}
