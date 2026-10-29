import 'package:test/test.dart';
import 'package:deutsch_build/src/features/exercises/generators/listening_phonetics_generator.dart';

void main() {
  group('ListeningPhoneticsExerciseGenerator Tests', () {
    late ListeningPhoneticsExerciseGenerator generator;

    setUp(() {
      generator = ListeningPhoneticsExerciseGenerator();
    });

    test('generate outputs an exercise with valid options and audioKey', () {
      final exercise = generator.generate();
      expect(exercise.exerciseId, isNotEmpty);
      expect(exercise.audioKey, isNotEmpty);
      expect(exercise.targetIpa, startsWith('['));
      expect(exercise.options, contains(exercise.expectedAnswer));
      expect(exercise.options.length, greaterThanOrEqualTo(2));
    });

    test('validateAnswer returns success on correct acoustic identification', () {
      final item = ListeningPhoneticsExerciseGenerator.defaultBank.first; // bieten
      final result = generator.validateAnswer(
        item: item,
        submittedAnswer: 'bieten',
      );

      expect(result.isCorrect, isTrue);
      expect(result.feedback, contains('ممتاز'));
    });

    test('validateAnswer provides phonetic contrast rule on incorrect answer', () {
      final item = ListeningPhoneticsExerciseGenerator.defaultBank.first; // bieten
      final result = generator.validateAnswer(
        item: item,
        submittedAnswer: 'bitten',
      );

      expect(result.isCorrect, isFalse);
      expect(result.feedback, contains('انتبه للفرق الصوتي'));
    });
  });
}
