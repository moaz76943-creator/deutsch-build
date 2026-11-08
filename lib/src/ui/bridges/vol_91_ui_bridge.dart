import '../../core/content/vol_91/vol_91_discourse.dart';
import '../../core/content/vol_91/vol_91_architecture_units.dart';

class Vol91UIBridge {
  static const int volume = 91;
  static const int startTaskId = 4221;
  static const int endTaskId = 4250;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol91DiscourseRegistry.items.length,
      'subsystems_count': Vol91SystemsDiagnostics.engines.length,
      'system_status': Vol91SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
