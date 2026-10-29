import 'package:deutsch_build/core/linguistics/relative_clause_engine.dart';

void main() {
  final engine = RelativeClauseEngine();

  // 1. فحص الاستثناء الحاسم في جر الجمع: Dativ Plural -> denen (وليس den)
  final resPluralDat = engine.resolvePronoun(
    antecedentGender: AntecedentGender.plural,
    internalCase: RelativeCase.dative,
  );
  assert(resPluralDat.pronoun == 'denen', 'Failed: Plural dative must be "denen"');

  // 2. فحص إضافة المذكر المحايد: Genitiv Maskulin -> dessen
  final resMascGen = engine.resolvePronoun(
    antecedentGender: AntecedentGender.masculine,
    internalCase: RelativeCase.genitive,
  );
  assert(resMascGen.pronoun == 'dessen');

  // 3. فحص إضافة المؤنث: Genitiv Feminin -> deren
  final resFemGen = engine.resolvePronoun(
    antecedentGender: AntecedentGender.feminine,
    internalCase: RelativeCase.genitive,
  );
  assert(resFemGen.pronoun == 'deren');

  // 4. فحص اقتران حرف الجر: mit dem
  final resPrep = engine.resolvePronoun(
    antecedentGender: AntecedentGender.masculine,
    internalCase: RelativeCase.dative,
    preposition: 'mit',
  );
  assert(resPrep.fullClauseOpening == 'mit dem');

  // 5. فحص موقع الفعل المصرف في نهاية جملة الصلة (Verbletzt)
  final validClause = ['der', 'in', 'Berlin', 'wohnt'];
  assert(engine.validateVerbFinalPlacement(validClause, 'wohnt'));

  final invalidClause = ['der', 'wohnt', 'in', 'Berlin'];
  assert(!engine.validateVerbFinalPlacement(invalidClause, 'wohnt'));

  print('Relative clause engine unit assertions passed.');
}
