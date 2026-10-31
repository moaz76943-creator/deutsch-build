import 'package:deutsch_build/core/exercises/passive_transformation_generator.dart';

void main() {
  final generator = PassiveTransformationExerciseGenerator();

  // 1. تمرين تحويل معلوم إلى مجهول حدثي: "Der Architekt baut das Haus" -> "Das Haus wird gebaut"
  final exVorgang = generator.generate(
    activeSentence: 'Der Architekt baut das Haus.',
    category: PassiveExerciseCategory.vorgangspassiv,
    correctPassiveForm: 'Das Haus wird gebaut.',
    plausibleDistractors: [
      'Das Haus ist gebaut.',
      'Das Haus wird bauen.',
      'Das Haus wurde gebaut.'
    ],
    arabicTranslation: 'البيت يُبنى.',
    ruleAr: 'في الحاضر نستخدم wird + Partizip II.',
  );

  assert(exVorgang.options.length == 4);
  assert(exVorgang.options.contains('Das Haus wird gebaut.'));
  assert(generator.validateAnswer('Das Haus wird gebaut.', exVorgang.correctPassiveForm) == true);
  assert(generator.validateAnswer('Das Haus ist gebaut.', exVorgang.correctPassiveForm) == false);

  // 2. تمرين بديل الباسيف: "Das Problem kann gelöst werden" -> "Das Problem lässt sich lösen"
  final exErsatz = generator.generate(
    activeSentence: 'Das Problem kann gelöst werden.',
    category: PassiveExerciseCategory.passiversatzSichLassen,
    correctPassiveForm: 'Das Problem lässt sich lösen.',
    plausibleDistractors: [
      'Das Problem ist zu lösen.',
      'Das Problem lässt lösen.',
      'Das Problem wird gelöst.'
    ],
    arabicTranslation: 'المشكلة يمكن حلها.',
    ruleAr: 'صيغة sich lassen + Infinitiv تعادل تماماً kann + Partizip II + werden.',
  );

  assert(exErsatz.options.contains('Das Problem lässt sich lösen.'));
  assert(generator.validateAnswer('Das Problem lässt sich lösen.', exErsatz.correctPassiveForm) == true);

  print('Passive transformation exercise generator unit assertions passed.');
}
