import 'package:deutsch_build/core/exercises/sentence_scramble_generator.dart';

void main() {
  final generator = SentenceScrambleExerciseGenerator();

  // 1. توليد تمرين ترتيب جملة ألمانية
  final exercise = generator.generate(
    germanSentence: 'Ich lerne heute Deutsch.',
    arabicTranslation: 'أنا أتعلم الألمانية اليوم.',
    cefrLevel: 'A1',
    deterministicSeed: 42,
  );

  assert(exercise.expectedSequence.length == 4);
  assert(exercise.scrambledTokens.length == 4);
  assert(exercise.scrambledTokens.contains('heute'));
  assert(exercise.scrambledTokens.contains('Deutsch'));

  // 2. فحص التحقق من إجابة المتعلم
  final correctOrder = ['Ich', 'lerne', 'heute', 'Deutsch'];
  final wrongOrder = ['heute', 'Ich', 'Deutsch', 'lerne'];

  assert(generator.validateLearnerAnswer(correctOrder, exercise.expectedSequence) == true);
  assert(generator.validateLearnerAnswer(wrongOrder, exercise.expectedSequence) == false);

  print('Sentence scramble exercise generator unit assertions passed.');
}
