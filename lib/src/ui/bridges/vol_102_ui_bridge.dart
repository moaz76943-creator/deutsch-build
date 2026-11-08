import '../../core/content/vol_102/vol_102_discourse.dart';
import '../../core/content/vol_102/vol_102_architecture_units.dart';

class Vol102UIBridge {
  static const int volume = 102;
  static const int startTaskId = 4551;
  static const int endTaskId = 4580;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol102DiscourseRegistry.items.length,
      'subsystems_count': Vol102SystemsDiagnostics.engines.length,
      'system_status': Vol102SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
