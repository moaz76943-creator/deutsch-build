import 'package:deutsch_build/core/exercises/preposition_selection_generator.dart';

void main() {
  final generator = PrepositionSelectionExerciseGenerator();

  // 1. توليد تمرين لفعل ينتظر: warten auf + Akkusativ
  final exWarten = generator.generate(
    prefixContext: 'Ich warte',
    verb: 'warten',
    suffixContext: 'den Bus.',
    correctPreposition: 'auf',
    requiredCase: 'Akkusativ',
    arabicTranslation: 'أنا أنتظر الحافلة.',
    explanationAr: 'الفعل warten يأخذ دائماً حرف الجر auf مع حالة النصب Akkusativ.',
    customDistractors: ['für', 'an', 'über'],
  );

  assert(exWarten.options.length == 4);
  assert(exWarten.options.contains('auf'));
  assert(exWarten.sentenceWithBlank == 'Ich warte [___] den Bus.');
  assert(generator.validateAnswer('auf', exWarten.correctPreposition) == true);
  assert(generator.validateAnswer('für', exWarten.correctPreposition) == false);

  // 2. توليد تمرين لفعل يشارك: teilnehmen an + Dativ
  final exTeilnehmen = generator.generate(
    prefixContext: 'Wir nehmen',
    verb: 'teilnehmen',
    suffixContext: 'dem Kurs teil.',
    correctPreposition: 'an',
    requiredCase: 'Dative',
    arabicTranslation: 'نحن نشارك في الدورة.',
    explanationAr: 'الفعل teilnehmen يأخذ حرف الجر an مع حالة الجر Dativ.',
  );

  assert(exTeilnehmen.options.contains('an'));
  assert(generator.validateAnswer('an', exTeilnehmen.correctPreposition) == true);

  print('Preposition selection exercise generator unit assertions passed.');
}
