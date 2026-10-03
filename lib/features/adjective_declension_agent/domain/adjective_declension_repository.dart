import 'adjective_declension_models.dart';

abstract interface class AdjectiveDeclensionRepository {
  Future<List<AdjectiveExerciseItem>> getExercises({
    DeclensionType? type,
  });

  Future<bool> checkAnswer(
    String exerciseId,
    String selectedEnding,
  );
}
