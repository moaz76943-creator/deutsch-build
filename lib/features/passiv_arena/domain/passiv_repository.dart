import 'passiv_models.dart';

abstract interface class PassivRepository {
  Future<List<PassivDrillItem>> getDrills({
    PassivType? type,
  });

  Future<bool> checkTransformation({
    required String drillId,
    required String auxiliaryForm,
    required String agentPreposition,
    required String partizipII,
  });
}
