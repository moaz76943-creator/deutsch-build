import '../../core/content/vol_72/vol_72_discourse.dart';
import '../../core/content/vol_72/vol_72_architecture_units.dart';

class Vol72UIBridge {
  static const int volume = 72;
  static const int startTaskId = 3651;
  static const int endTaskId = 3680;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol72DiscourseRegistry.items.length,
      'subsystems_count': Vol72SystemsDiagnostics.engines.length,
      'system_status': Vol72SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
