import '../../core/content/vol_92/vol_92_discourse.dart';
import '../../core/content/vol_92/vol_92_architecture_units.dart';

class Vol92UIBridge {
  static const int volume = 92;
  static const int startTaskId = 4251;
  static const int endTaskId = 4280;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol92DiscourseRegistry.items.length,
      'subsystems_count': Vol92SystemsDiagnostics.engines.length,
      'system_status': Vol92SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
