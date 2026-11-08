import '../../core/content/vol_80/vol_80_discourse.dart';
import '../../core/content/vol_80/vol_80_architecture_units.dart';

class Vol80UIBridge {
  static const int volume = 80;
  static const int startTaskId = 3891;
  static const int endTaskId = 3920;
  static const String landmark = "LANDMARK_3900_AND_VOL80_SEALED";

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'landmark': landmark,
      'linguistic_count': Vol80DiscourseRegistry.items.length,
      'subsystems_count': Vol80SystemsDiagnostics.engines.length,
      'system_status': Vol80SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
