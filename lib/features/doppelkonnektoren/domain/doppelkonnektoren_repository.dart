import 'doppelkonnektoren_models.dart';

abstract class DoppelkonnektorenRepository {
  Future<List<DoppelConnectorChallengeItem>> getChallenges({
    DoppelConnectorType? type,
  });

  Future<List<String>> getConnectorOptions(String challengeId);

  Future<bool> validateConnectorPair(
    String challengeId,
    String firstPart,
    String secondPart,
  );

  Future<bool> validateSentence(
    String challengeId,
    String sentence,
  );
}
