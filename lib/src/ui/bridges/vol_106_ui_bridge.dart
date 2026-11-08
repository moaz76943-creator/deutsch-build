import '../../core/content/vol_106/vol_106_discourse.dart';
import '../../core/content/vol_106/vol_106_architecture_units.dart';

class Vol106UIBridge {
  static const int volume = 106;
  static const int startTaskId = 4671;
  static const int endTaskId = 4700;
  static const String landmark = "LANDMARK_4700_SEALED";

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'landmark': landmark,
      'linguistic_count': Vol106DiscourseRegistry.items.length,
      'subsystems_count': Vol106SystemsDiagnostics.engines.length,
      'system_status': Vol106SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
