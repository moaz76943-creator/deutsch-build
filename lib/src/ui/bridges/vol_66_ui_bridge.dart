import '../../core/content/vol_66/vol_66_discourse.dart';
import '../../core/content/vol_66/vol_66_architecture_units.dart';

class Vol66UIBridge {
  static const int volume = 66;
  static const int startTaskId = 3471;
  static const int endTaskId = 3500;
  static const String landmark = "LANDMARK_3500_SEALED";

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'landmark': landmark,
      'linguistic_count': Vol66DiscourseRegistry.items.length,
      'subsystems_count': Vol66SystemsDiagnostics.engines.length,
      'system_status': Vol66SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
