/// Detected audio output routing destination.
enum AudioRouteType {
  builtInSpeaker, // ~10-20ms latency
  wiredHeadset,   // ~15-25ms latency
  bluetoothA2dp,  // ~120-220ms latency
  bluetoothSco,   // ~80-150ms latency (headset profile)
}

/// Dynamic latency compensation calibration profile.
class LatencyCalibrationProfile {
  final AudioRouteType routeType;
  final Duration estimatedHardwareLatency;

  const LatencyCalibrationProfile({
    required this.routeType,
    required this.estimatedHardwareLatency,
  });
}

/// Automatically offsets audio-visual timestamps based on active hardware route.
class HeadsetLatencyCompensator {
  AudioRouteType _activeRoute = AudioRouteType.builtInSpeaker;

  HeadsetLatencyCompensator();

  AudioRouteType get activeRoute => _activeRoute;

  /// Updates current audio output route.
  void updateRoute(AudioRouteType route) {
    _activeRoute = route;
  }

  /// Calculates dynamic hardware latency compensation offset.
  Duration getCompensationOffset() {
    switch (_activeRoute) {
      case AudioRouteType.builtInSpeaker:
        return const Duration(milliseconds: 15);
      case AudioRouteType.wiredHeadset:
        return const Duration(milliseconds: 20);
      case AudioRouteType.bluetoothSco:
        return const Duration(milliseconds: 100);
      case AudioRouteType.bluetoothA2dp:
        return const Duration(milliseconds: 180);
    }
  }

  /// Adjusts raw recording timestamp by removing audio pipeline latency.
  Duration calibrateRecordingTimestamp(Duration rawTimestamp) {
    final offset = getCompensationOffset();
    if (rawTimestamp < offset) return Duration.zero;
    return rawTimestamp - offset;
  }
}
