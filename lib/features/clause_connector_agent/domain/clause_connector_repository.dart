import 'clause_connector_models.dart';

abstract class ClauseConnectorRepository {
  Future<List<ConnectorChallengeItem>> getChallenges({
    ConjunctionType? type,
  });

  Future<bool> validateConnection(
    String challengeId,
    String constructedClause,
  );
}
