import '../../core/content/vol_64/vol_64_discourse.dart';
import '../../core/content/vol_64/vol_64_architecture_units.dart';

class Vol64UIBridge {
  static const int volume = 64;
  static const int startTaskId = 3411;
  static const int endTaskId = 3440;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol64DiscourseRegistry.items.length,
      'subsystems_count': Vol64SystemsDiagnostics.engines.length,
      'system_status': Vol64SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
