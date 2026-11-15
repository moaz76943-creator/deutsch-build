import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/features/exercises/generators/compound_decomposition_generator.dart';

void main() {
  group('CompoundDecompositionExerciseGenerator Tests', () {
    late CompoundDecompositionExerciseGenerator generator;

    setUp(() {
      generator = CompoundDecompositionExerciseGenerator();
    });

    test('generate produces valid exercise with expected components and article', () {
      final exercise = generator.generate();
      expect(exercise.exerciseId, isNotEmpty);
      expect(exercise.compoundLemma, isNotEmpty);
      expect(exercise.targetComponents, isNotEmpty);
      expect(exercise.availableTokens.length, greaterThanOrEqualTo(exercise.targetComponents.length));
      expect(exercise.articleOptions, contains(exercise.expectedArticle));
    });

    test('validateAnswer detects correct decomposition and correct article', () {
      final item = CompoundDecompositionExerciseGenerator.defaultBank.first;
      final result = generator.validateAnswer(
        item: item,
        submittedComponents: ['Hand', 'Schuh'],
        submittedArticle: 'der',
      );

      expect(result.isFullyCorrect, isTrue);
      expect(result.isArticleCorrect, isTrue);
      expect(result.isDecompositionCorrect, isTrue);
    });

    test('validateAnswer warns when article is wrong based on head noun', () {
      final item = CompoundDecompositionExerciseGenerator.defaultBank.first;
      final result = generator.validateAnswer(
        item: item,
        submittedComponents: ['Hand', 'Schuh'],
        submittedArticle: 'die', // Wrong: Hand is die, but Schuh is der!
      );

      expect(result.isFullyCorrect, isFalse);
      expect(result.isArticleCorrect, isFalse);
      expect(result.isDecompositionCorrect, isTrue);
    });
  });
}
