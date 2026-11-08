import '../../core/content/vol_105/vol_105_discourse.dart';
import '../../core/content/vol_105/vol_105_architecture_units.dart';

class Vol105UIBridge {
  static const int volume = 105;
  static const int startTaskId = 4641;
  static const int endTaskId = 4670;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol105DiscourseRegistry.items.length,
      'subsystems_count': Vol105SystemsDiagnostics.engines.length,
      'system_status': Vol105SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
