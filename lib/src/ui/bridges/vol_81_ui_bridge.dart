import '../../core/content/vol_81/vol_81_discourse.dart';
import '../../core/content/vol_81/vol_81_architecture_units.dart';

class Vol81UIBridge {
  static const int volume = 81;
  static const int startTaskId = 3921;
  static const int endTaskId = 3950;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol81DiscourseRegistry.items.length,
      'subsystems_count': Vol81SystemsDiagnostics.engines.length,
      'system_status': Vol81SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
