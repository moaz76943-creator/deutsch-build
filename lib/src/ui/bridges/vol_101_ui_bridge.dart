import '../../core/content/vol_101/vol_101_discourse.dart';
import '../../core/content/vol_101/vol_101_architecture_units.dart';

class Vol101UIBridge {
  static const int volume = 101;
  static const int startTaskId = 4521;
  static const int endTaskId = 4550;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol101DiscourseRegistry.items.length,
      'subsystems_count': Vol101SystemsDiagnostics.engines.length,
      'system_status': Vol101SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
