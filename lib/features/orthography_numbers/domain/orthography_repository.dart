import 'orthography_models.dart';

abstract interface class OrthographyRepository {
  List<OrthographyExercise> get allExercises;

  List<OrthographyExercise> forTopic(OrthographyTopic topic);

  OrthographyExercise? byId(String id);

  bool isCommaPlacementCorrect(
    OrthographyExercise exercise,
    Set<int> selectedGaps,
  );

  bool isTextAnswerCorrect(
    OrthographyExercise exercise,
    String answer,
  );

  String formatDateLong(DateTime date);

  String formatDateNumeric(DateTime date);

  String formatNumber(String canonicalNumber);

  String renderCommaSentence(
    OrthographyExercise exercise,
    Set<int> selectedGaps,
  );

  String normalizeTextAnswer(String value);
}
