import '../../core/content/vol_82/vol_82_discourse.dart';
import '../../core/content/vol_82/vol_82_architecture_units.dart';

class Vol82UIBridge {
  static const int volume = 82;
  static const int startTaskId = 3951;
  static const int endTaskId = 3980;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol82DiscourseRegistry.items.length,
      'subsystems_count': Vol82SystemsDiagnostics.engines.length,
      'system_status': Vol82SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
