import 'cognitive_load_models.dart';

abstract interface class PacingRepository {
  Future<void> record(SessionTelemetry telemetry);
  Future<List<SessionTelemetry>> recent({required int limit});
  Future<void> clear();
}
