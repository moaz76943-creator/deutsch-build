import '../../core/content/vol_67/vol_67_discourse.dart';
import '../../core/content/vol_67/vol_67_architecture_units.dart';

class Vol67UIBridge {
  static const int volume = 67;
  static const int startTaskId = 3501;
  static const int endTaskId = 3530;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol67DiscourseRegistry.items.length,
      'subsystems_count': Vol67SystemsDiagnostics.engines.length,
      'system_status': Vol67SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
