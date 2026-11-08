import '../../core/content/vol_71/vol_71_discourse.dart';
import '../../core/content/vol_71/vol_71_architecture_units.dart';

class Vol71UIBridge {
  static const int volume = 71;
  static const int startTaskId = 3621;
  static const int endTaskId = 3650;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol71DiscourseRegistry.items.length,
      'subsystems_count': Vol71SystemsDiagnostics.engines.length,
      'system_status': Vol71SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
