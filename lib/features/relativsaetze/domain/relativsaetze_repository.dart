import 'relativsaetze_models.dart';

abstract class RelativsaetzeRepository {
  Future<List<RelativeClauseChallengeItem>> getChallenges({
    RelativeClauseFocus? focus,
  });

  Future<List<String>> getAnswerOptions(String challengeId);

  Future<bool> validatePronoun(
    String challengeId,
    String pronoun,
  );

  Future<bool> validateSentence(
    String challengeId,
    String sentence,
  );
}
