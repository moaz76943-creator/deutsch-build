import '../../core/content/vol_75/vol_75_discourse.dart';
import '../../core/content/vol_75/vol_75_architecture_units.dart';

class Vol75UIBridge {
  static const int volume = 75;
  static const int startTaskId = 3741;
  static const int endTaskId = 3770;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol75DiscourseRegistry.items.length,
      'subsystems_count': Vol75SystemsDiagnostics.engines.length,
      'system_status': Vol75SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
