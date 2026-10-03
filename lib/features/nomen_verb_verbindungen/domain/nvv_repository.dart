import 'nvv_models.dart';

abstract class NvvRepository {
  Future<List<NvvChallengeItem>> getChallenges({
    NvvRegister? register,
  });

  Future<List<NvvChallengeItem>> search(String query);

  Future<bool> validateAnswer(
    String challengeId,
    String selectedVerb,
  );
}
