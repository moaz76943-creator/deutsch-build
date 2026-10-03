import 'partizip_models.dart';

abstract interface class PartizipRepository {
  List<PartizipExercise> get allExercises;

  List<PartizipExercise> forKind(PartizipKind kind);

  PartizipExercise? byId(String id);

  bool isAnswerCorrect(
    PartizipExercise exercise,
    String candidate,
  );

  bool isTokenOrderCorrect(
    PartizipExercise exercise,
    List<String> candidateTokens,
  );

  String normalizeAnswer(String value);
}
