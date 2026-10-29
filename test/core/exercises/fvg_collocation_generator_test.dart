import 'package:deutsch_build/core/exercises/fvg_collocation_generator.dart';

void main() {
  final generator = FvgCollocationExerciseGenerator();

  // 1. توليد تمرين: اتخاذ قرار (eine Entscheidung treffen = entscheiden)
  final exEntscheidung = generator.generate(
    prefixContext: 'Wir müssen heute',
    nounPhrase: 'eine Entscheidung',
    suffixContext: '.',
    correctFunctionVerb: 'treffen',
    simpleVerbEquivalent: 'entscheiden',
    translationAr: 'يجب علينا اليوم اتخاذ قرار.',
    explanationAr: 'المتلازمة الصحيحة هي "eine Entscheidung treffen" وتعادل الفعل البسيط entscheiden.',
    plausibleDistractors: ['machen', 'tun', 'nehmen'],
  );

  assert(exEntscheidung.verbOptions.length == 4);
  assert(exEntscheidung.verbOptions.contains('treffen'));
  assert(exEntscheidung.sentenceWithBlank.contains('[___]'));
  assert(generator.validateAnswer('treffen', exEntscheidung.correctFunctionVerb) == true);
  assert(generator.validateAnswer('machen', exEntscheidung.correctFunctionVerb) == false);

  // 2. توليد تمرين: تحت التصرف (zur Verfügung stehen = verfügbar sein)
  final exVerfuegung = generator.generate(
    prefixContext: 'Das Auto steht Ihnen',
    nounPhrase: 'zur Verfügung',
    suffixContext: '.',
    correctFunctionVerb: 'stehen',
    simpleVerbEquivalent: 'verfügbar sein',
    translationAr: 'السيارة متاحة تحت تصرفك.',
    explanationAr: 'المتلازمة "zur Verfügung stehen" تعني أن الشيء متاح وحاضر.',
    plausibleDistractors: ['stellen', 'bringen', 'legen'],
  );

  assert(exVerfuegung.verbOptions.contains('stehen'));
  assert(generator.validateAnswer('stehen', exVerfuegung.correctFunctionVerb) == true);

  print('FVG collocation exercise generator unit assertions passed.');
}
