import 'package:deutsch_build/core/exercises/cloze_test_generator.dart';

void main() {
  final generator = ClozeTestGenerator();

  // 1. توليد تمرين لإعراب صفة في حالة النصب المذكر: "Ich trinke einen kalt[___] Kaffee."
  final exercise = generator.generateAdjectiveCloze(
    prefixContext: 'Ich trinke einen',
    baseAdjective: 'kalt',
    suffixContext: 'Kaffee.',
    correctEnding: 'en',
    arabicTranslation: 'أنا أشرب قهوة باردة.',
    grammarHint: 'Akkusativ Maskulin بعد أداة النكرة يفرض اللاحقة -en',
  );

  assert(exercise.sentenceWithBlank.contains('kalt[___]'));
  assert(exercise.correctEnding == 'en');
  assert(exercise.endingOptions.contains('en'));
  assert(exercise.endingOptions.length >= 4);

  // 2. التحقق من تصحيح الإجابة
  assert(generator.validateAnswer('en', exercise.correctEnding) == true);
  assert(generator.validateAnswer('e', exercise.correctEnding) == false);

  print('Cloze test generator unit assertions passed.');
}
