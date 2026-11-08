import '../../core/content/vol_95/vol_95_discourse.dart';
import '../../core/content/vol_95/vol_95_architecture_units.dart';

enum BridgeOperationalStatus { optimal, degraded }

final class VolumeSummary {
  final int volume;
  final int startTaskId;
  final int endTaskId;
  final String landmark;
  final int linguisticCount;
  final int subsystemsCount;
  final BridgeOperationalStatus status;

  const VolumeSummary({
    required this.volume,
    required this.startTaskId,
    required this.endTaskId,
    required this.landmark,
    required this.linguisticCount,
    required this.subsystemsCount,
    required this.status,
  });
}

final class Vol95UIBridge {
  static const int volume = 95;
  static const int startTaskId = 4341;
  static const int endTaskId = 4370;
  static const String landmark = "LANDMARK_4370_SEALED";

  static VolumeSummary getSummary() {
    final ok = Vol95SystemsDiagnostics.runSelfDiagnostics();
    return VolumeSummary(
      volume: volume,
      startTaskId: startTaskId,
      endTaskId: endTaskId,
      landmark: landmark,
      linguisticCount: Vol95DiscourseRegistry.items.length,
      subsystemsCount: Vol95SystemsDiagnostics.engines.length,
      status: ok ? BridgeOperationalStatus.optimal : BridgeOperationalStatus.degraded,
    );
  }
}
