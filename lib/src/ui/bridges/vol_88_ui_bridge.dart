import '../../core/content/vol_88/vol_88_discourse.dart';
import '../../core/content/vol_88/vol_88_architecture_units.dart';

class Vol88UIBridge {
  static const int volume = 88;
  static const int startTaskId = 4131;
  static const int endTaskId = 4160;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol88DiscourseRegistry.items.length,
      'subsystems_count': Vol88SystemsDiagnostics.engines.length,
      'system_status': Vol88SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
