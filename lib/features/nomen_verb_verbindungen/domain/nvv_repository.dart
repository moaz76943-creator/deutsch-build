import 'nvv_models.dart';

abstract class NvvRepository {
  Future<List<NvvChallengeItem>> getChallenges({
    NvvRegister? register,
    NvvContext? context,
  });

  Future<List<NvvChallengeItem>> search(String query);

  Future<bool> validateAnswer(
    String challengeId,
    String selectedVerb,
  );

  Future<bool> validateReplacement(
    String challengeId,
    ReplacementDirection direction,
    String candidate,
  );
}
