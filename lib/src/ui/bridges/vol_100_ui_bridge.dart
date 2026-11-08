import '../../core/content/vol_100/vol_100_discourse.dart';
import '../../core/content/vol_100/vol_100_architecture_units.dart';

class Vol100UIBridge {
  static const int volume = 100;
  static const int startTaskId = 4491;
  static const int endTaskId = 4520;
  static const String landmark = "HISTORIC_CENTURY_100_VOLUMES_SEALED";

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'landmark': landmark,
      'linguistic_count': Vol100DiscourseRegistry.items.length,
      'subsystems_count': Vol100SystemsDiagnostics.engines.length,
      'system_status': Vol100SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
