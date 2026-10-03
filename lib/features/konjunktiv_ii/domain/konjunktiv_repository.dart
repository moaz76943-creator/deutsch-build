import 'konjunktiv_models.dart';

abstract class KonjunktivRepository {
  Future<List<KonjunktivChallengeItem>> getChallenges({
    KonjunktivUsage? usage,
  });

  Future<List<String>> getAnswerOptions(String challengeId);

  Future<bool> validateConjugation(
    String challengeId,
    String conjugatedForm,
  );

  Future<bool> validateSentence(
    String challengeId,
    String constructedSentence,
  );
}
