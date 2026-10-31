import 'prefix_models.dart';

abstract interface class PrefixRepository {
  Future<List<PrefixDrillItem>> getDrills({
    VerbPrefixClass? verbClass,
  });

  Future<bool> checkAnswer({
    required String drillId,
    required String answer,
  });
}
