import '../../core/content/vol_97/vol_97_discourse.dart';
import '../../core/content/vol_97/vol_97_architecture_units.dart';

class Vol97UIBridge {
  static const int volume = 97;
  static const int startTaskId = 4401;
  static const int endTaskId = 4430;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol97DiscourseRegistry.items.length,
      'subsystems_count': Vol97SystemsDiagnostics.engines.length,
      'system_status': Vol97SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
