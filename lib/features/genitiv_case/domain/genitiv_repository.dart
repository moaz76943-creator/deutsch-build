import 'genitiv_models.dart';

abstract class GenitivRepository {
  Future<List<GenitivChallengeItem>> getChallenges({
    GenitivDrillType? type,
  });

  Future<bool> validateAnswer(
    String challengeId, {
    required String chosenArticle,
    required String chosenNounSuffix,
    String? chosenPreposition,
  });
}
