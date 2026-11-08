import '../../core/content/vol_77/vol_77_discourse.dart';
import '../../core/content/vol_77/vol_77_architecture_units.dart';

class Vol77UIBridge {
  static const int volume = 77;
  static const int startTaskId = 3801;
  static const int endTaskId = 3830;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol77DiscourseRegistry.items.length,
      'subsystems_count': Vol77SystemsDiagnostics.engines.length,
      'system_status': Vol77SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
