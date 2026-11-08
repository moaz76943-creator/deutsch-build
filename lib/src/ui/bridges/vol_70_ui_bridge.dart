import '../../core/content/vol_70/vol_70_discourse.dart';
import '../../core/content/vol_70/vol_70_architecture_units.dart';

class Vol70UIBridge {
  static const int volume = 70;
  static const int startTaskId = 3591;
  static const int endTaskId = 3620;
  static const String landmark = "LANDMARK_3600_AND_VOL70_SEALED";

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'landmark': landmark,
      'linguistic_count': Vol70DiscourseRegistry.items.length,
      'subsystems_count': Vol70SystemsDiagnostics.engines.length,
      'system_status': Vol70SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
