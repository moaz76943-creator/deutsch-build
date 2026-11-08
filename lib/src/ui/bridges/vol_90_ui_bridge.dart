import '../../core/content/vol_90/vol_90_discourse.dart';
import '../../core/content/vol_90/vol_90_architecture_units.dart';

class Vol90UIBridge {
  static const int volume = 90;
  static const int startTaskId = 4191;
  static const int endTaskId = 4220;
  static const String landmark = "LANDMARK_4200_SEALED";

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'landmark': landmark,
      'linguistic_count': Vol90DiscourseRegistry.items.length,
      'subsystems_count': Vol90SystemsDiagnostics.engines.length,
      'system_status': Vol90SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
