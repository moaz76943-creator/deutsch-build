import 'package:deutsch_build/core/exercises/verb_conjugation_generator.dart';

void main() {
  final generator = VerbConjugationExerciseGenerator();

  // 1. فحص تمرين تصريف مضارع مع إبدال صوتي: fahren مع du -> fährst
  final exPresent = generator.generate(
    infinitiv: 'fahren',
    pronoun: 'du',
    mode: TenseExerciseMode.present,
    correctForm: 'fährst',
    plausibleDistractors: ['fahrt', 'fahre', 'fährt'],
    explanationAr: 'الفعل fahren يحدث فيه إبدال صوتي (a -> ä) مع du و er/sie/es.',
  );

  assert(exPresent.options.length == 4);
  assert(exPresent.options.contains('fährst'));
  assert(generator.validateAnswer('fährst', exPresent.correctForm) == true);
  assert(generator.validateAnswer('fahrt', exPresent.correctForm) == false);

  // 2. فحص تمرين ماضي تام (Perfekt) مع فعل حركة: bleiben -> ist geblieben
  final exPerfekt = generator.generate(
    infinitiv: 'bleiben',
    pronoun: 'er',
    mode: TenseExerciseMode.perfekt,
    correctForm: 'ist geblieben',
    plausibleDistractors: ['hat geblieben', 'ist gebleibt', 'hat gebleibt'],
    explanationAr: 'الفعل bleiben يأخذ دائماً الفعل المساعد sein في الماضي التام.',
  );

  assert(exPerfekt.options.contains('ist geblieben'));
  assert(generator.validateAnswer('ist geblieben', exPerfekt.correctForm) == true);
  assert(generator.validateAnswer('hat geblieben', exPerfekt.correctForm) == false);

  print('Verb conjugation exercise generator unit assertions passed.');
}
