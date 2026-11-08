import '../../core/content/vol_73/vol_73_discourse.dart';
import '../../core/content/vol_73/vol_73_architecture_units.dart';

class Vol73UIBridge {
  static const int volume = 73;
  static const int startTaskId = 3681;
  static const int endTaskId = 3710;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol73DiscourseRegistry.items.length,
      'subsystems_count': Vol73SystemsDiagnostics.engines.length,
      'system_status': Vol73SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
