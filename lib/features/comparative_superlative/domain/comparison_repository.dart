import 'comparison_models.dart';

abstract interface class ComparisonRepository {
  Future<List<ComparisonChallengeItem>> getChallenges({
    ComparisonRuleType? ruleType,
  });

  Future<bool> checkForm(
    String challengeId,
    ComparisonDegree degree,
    String answer,
  );

  Future<bool> checkConnector(
    String challengeId,
    ComparisonDegree degree,
    String connector,
  );
}
