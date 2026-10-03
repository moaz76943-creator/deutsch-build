import 'conjunctions_models.dart';

abstract class ConjunctionsRepository {
  Future<List<ConjunctionDrillItem>> getDrills({
    ConjunctionCategory? category,
  });

  Future<bool> validateAnswer(
    String drillId,
    String chosenConnector,
    int chosenVerbPosition,
  );
}
