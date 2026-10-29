import 'package:deutsch_build/core/exercises/modalpartikeln_exercise_generator.dart';

void main() {
  final generator = ModalpartikelnExerciseGenerator();

  // 1. توليد تمرين لتلطيف صيغة الأمر باستخدام mal
  final exMal = generator.generate(
    dialogueSnippet: 'Komm [___] her!',
    correctParticle: 'mal',
    pragmaticToneAr: 'تلطيف الأمر وإضفاء الود والتهذيب',
    translationAr: 'تعال إلى هنا لو سمحت!',
    pedagogicalRuleAr: 'الأداة mal تخفف من حدة الأمر وتجعله طلباً مهذباً.',
    candidateDistractors: ['denn', 'halt', 'ja'],
  );

  assert(exMal.options.length == 4);
  assert(exMal.options.contains('mal'));
  assert(generator.validateAnswer('mal', exMal.correctParticle) == true);
  assert(generator.validateAnswer('denn', exMal.correctParticle) == false);

  // 2. توليد تمرين للتذكير بالحجة أو الاعتراض باستخدام doch
  final exDoch = generator.generate(
    dialogueSnippet: 'Das ist [___] klar!',
    correctParticle: 'doch',
    pragmaticToneAr: 'تأكيد البديهيات وتصحيح سوء الفهم',
    translationAr: 'هذا أمر واضح وبديهي بالطبع!',
    pedagogicalRuleAr: 'الأداة doch تُستخدم للتذكير بحقيقة واضحة للطرفين.',
  );

  assert(exDoch.options.contains('doch'));
  assert(generator.validateAnswer('doch', exDoch.correctParticle) == true);

  print('Modalpartikeln exercise generator unit assertions passed.');
}
