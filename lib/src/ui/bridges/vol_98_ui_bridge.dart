import '../../core/content/vol_98/vol_98_discourse.dart';
import '../../core/content/vol_98/vol_98_architecture_units.dart';

class Vol98UIBridge {
  static const int volume = 98;
  static const int startTaskId = 4431;
  static const int endTaskId = 4460;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol98DiscourseRegistry.items.length,
      'subsystems_count': Vol98SystemsDiagnostics.engines.length,
      'system_status': Vol98SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
