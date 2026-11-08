import '../../core/content/vol_96/vol_96_discourse.dart';
import '../../core/content/vol_96/vol_96_architecture_units.dart';

class Vol96UIBridge {
  static const int volume = 96;
  static const int startTaskId = 4371;
  static const int endTaskId = 4400;
  static const String landmark = "LANDMARK_4400_SEALED";

  static Map<String, dynamic> getSummary() {
    return {
      'volume': volume,
      'range': '$startTaskId-$endTaskId',
      'landmark': landmark,
      'linguistic_count': Vol96DiscourseRegistry.items.length,
      'subsystems_count': Vol96SystemsDiagnostics.engines.length,
      'system_status': Vol96SystemsDiagnostics.runSelfDiagnostics() ? 'OPTIMAL' : 'DEGRADED',
    };
  }
}
