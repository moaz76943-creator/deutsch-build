import 'separable_verbs_models.dart';

abstract class SeparableVerbsRepository {
  Future<List<VerbPrefixDrillItem>> getDrills();

  Future<bool> validateAnswer({
    required String drillId,
    required PrefixPlacement selectedPlacement,
    required String conjugatedVerb,
  });
}
