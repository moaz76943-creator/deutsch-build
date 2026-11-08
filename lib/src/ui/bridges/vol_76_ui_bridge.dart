import '../../core/content/vol_76/vol_76_discourse.dart';
import '../../core/content/vol_76/vol_76_architecture_units.dart';

class Vol76UIBridge {
  static const int volume = 76;
  static const int startTaskId = 3771;
  static const int endTaskId = 3800;
  static const String landmark = "LANDMARK_3800_SEALED";

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'landmark': landmark,
      'linguistic_count': Vol76DiscourseRegistry.items.length,
      'subsystems_count': Vol76SystemsDiagnostics.engines.length,
      'system_status': Vol76SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
