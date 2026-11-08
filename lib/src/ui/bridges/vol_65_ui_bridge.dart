import '../../core/content/vol_65/vol_65_discourse.dart';
import '../../core/content/vol_65/vol_65_architecture_units.dart';

class Vol65UIBridge {
  static const int volume = 65;
  static const int startTaskId = 3441;
  static const int endTaskId = 3470;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol65DiscourseRegistry.items.length,
      'subsystems_count': Vol65SystemsDiagnostics.engines.length,
      'system_status': Vol65SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
