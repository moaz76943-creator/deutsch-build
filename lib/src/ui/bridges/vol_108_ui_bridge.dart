import '../../core/content/vol_108/vol_108_discourse.dart';
import '../../core/content/vol_108/vol_108_architecture_units.dart';

class Vol108UIBridge {
  static const int volume = 108;
  static const int startTaskId = 4731;
  static const int endTaskId = 4760;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol108DiscourseRegistry.items.length,
      'subsystems_count': Vol108SystemsDiagnostics.engines.length,
      'system_status': Vol108SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
