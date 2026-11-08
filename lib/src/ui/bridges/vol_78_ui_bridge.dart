import '../../core/content/vol_78/vol_78_discourse.dart';
import '../../core/content/vol_78/vol_78_architecture_units.dart';

class Vol78UIBridge {
  static const int volume = 78;
  static const int startTaskId = 3831;
  static const int endTaskId = 3860;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol78DiscourseRegistry.items.length,
      'subsystems_count': Vol78SystemsDiagnostics.engines.length,
      'system_status': Vol78SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
