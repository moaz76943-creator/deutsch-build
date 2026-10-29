import 'dart:async';

/// Thermal operational state of mobile hardware.
enum DeviceThermalStatus {
  normal,   // Cool / normal operation
  moderate, // Elevated temperature (apply light throttling)
  severe,   // High temperature (aggressive throttling)
  critical, // Immediate safety fallback
}

/// Operational quality tier dictating rendering and synthesis overhead.
enum OperationalQualityTier {
  fullFidelity, // 60fps animations, full neural synthesis
  balanced,     // Standard animations, regular synthesis
  ecoSaver,     // Minimal visualizer, cached audio preference
}

/// Platform bridge providing battery and thermal telemetry.
abstract class DeviceTelemetrySource {
  Future<int> getBatteryLevelPercentage();
  Future<bool> isCharging();
  Future<DeviceThermalStatus> getThermalStatus();
}

/// Manages performance throttling based on battery and thermal constraints.
class AdaptiveThermalBatteryManager {
  final DeviceTelemetrySource telemetry;

  OperationalQualityTier _currentTier = OperationalQualityTier.fullFidelity;
  final StreamController<OperationalQualityTier> _tierController =
      StreamController<OperationalQualityTier>.broadcast();

  AdaptiveThermalBatteryManager({required this.telemetry});

  OperationalQualityTier get currentTier => _currentTier;
  Stream<OperationalQualityTier> get tierStream => _tierController.stream;

  /// Audits device status and updates operational tier.
  Future<OperationalQualityTier> evaluateAndApplyPolicy() async {
    final battery = await telemetry.getBatteryLevelPercentage();
    final isCharging = await telemetry.isCharging();
    final thermal = await telemetry.getThermalStatus();

    OperationalQualityTier newTier;

    if (thermal == DeviceThermalStatus.critical || (battery < 15 && !isCharging)) {
      newTier = OperationalQualityTier.ecoSaver;
    } else if (thermal == DeviceThermalStatus.severe || thermal == DeviceThermalStatus.moderate || (battery < 30 && !isCharging)) {
      newTier = OperationalQualityTier.balanced;
    } else {
      newTier = OperationalQualityTier.fullFidelity;
    }

    if (_currentTier != newTier) {
      _currentTier = newTier;
      _tierController.add(_currentTier);
    }

    return _currentTier;
  }

  /// Whether heavy background tasks (FSRS-5 batch compaction) are permitted.
  bool canRunBackgroundMaintenance({required int batteryLevel, required bool isCharging}) {
    return isCharging || batteryLevel >= 50;
  }

  void dispose() {
    _tierController.close();
  }
}
