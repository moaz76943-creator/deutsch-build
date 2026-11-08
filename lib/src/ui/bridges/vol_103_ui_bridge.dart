import '../../core/content/vol_103/vol_103_discourse.dart';
import '../../core/content/vol_103/vol_103_architecture_units.dart';

class Vol103UIBridge {
  static const int volume = 103;
  static const int startTaskId = 4581;
  static const int endTaskId = 4610;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol103DiscourseRegistry.items.length,
      'subsystems_count': Vol103SystemsDiagnostics.engines.length,
      'system_status': Vol103SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
