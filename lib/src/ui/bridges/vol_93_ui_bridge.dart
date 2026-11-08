import '../../core/content/vol_93/vol_93_discourse.dart';
import '../../core/content/vol_93/vol_93_architecture_units.dart';

class Vol93UIBridge {
  static const int volume = 93;
  static const int startTaskId = 4281;
  static const int endTaskId = 4310;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol93DiscourseRegistry.items.length,
      'subsystems_count': Vol93SystemsDiagnostics.engines.length,
      'system_status': Vol93SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
