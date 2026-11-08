import '../../core/content/vol_68/vol_68_discourse.dart';
import '../../core/content/vol_68/vol_68_architecture_units.dart';

class Vol68UIBridge {
  static const int volume = 68;
  static const int startTaskId = 3531;
  static const int endTaskId = 3560;

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'linguistic_count': Vol68DiscourseRegistry.items.length,
      'subsystems_count': Vol68SystemsDiagnostics.engines.length,
      'system_status': Vol68SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
