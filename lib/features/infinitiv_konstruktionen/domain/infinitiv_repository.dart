import 'infinitiv_models.dart';

abstract class InfinitivRepository {
  Future<List<InfinitivChallengeItem>> getChallenges({
    InfinitivClauseType? type,
  });

  Future<bool> validateAnswer(
    String challengeId,
    String constructedClause,
  );
}
