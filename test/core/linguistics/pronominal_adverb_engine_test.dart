import 'package:deutsch_build/core/linguistics/pronominal_adverb_engine.dart';

void main() {
  final engine = PronominaladverbienEngine();

  // 1. الأشياء مع حرف علة (an): daran / woran (مع إدماج r)
  final resAnObject = engine.generate(preposition: 'an', referent: ReferentNature.objectOrConcept);
  assert(resAnObject.statementForm == 'daran');
  assert(resAnObject.questionForm == 'woran');
  assert(resAnObject.isPronominalAdverb);

  // 2. الأشخاص مع حرف علة (an): an ihn / an wen (دون دمج da-/wo-)
  final resAnPerson = engine.generate(
    preposition: 'an',
    referent: ReferentNature.person,
    personalPronoun: 'ihn',
    questionPronoun: 'wen',
  );
  assert(resAnPerson.statementForm == 'an ihn');
  assert(resAnPerson.questionForm == 'an wen');
  assert(!resAnPerson.isPronominalAdverb);

  // 3. الأشياء مع حرف ساكن (mit): damit / womit (دون r)
  final resMitObject = engine.generate(preposition: 'mit', referent: ReferentNature.objectOrConcept);
  assert(resMitObject.statementForm == 'damit');
  assert(resMitObject.questionForm == 'womit');

  // 4. الأشياء مع حرف علة (über): darüber / worüber
  final resUeber = engine.generate(preposition: 'über', referent: ReferentNature.objectOrConcept);
  assert(resUeber.statementForm == 'darüber');
  assert(resUeber.questionForm == 'worüber');

  print('Pronominaladverbien engine assertions passed.');
}
