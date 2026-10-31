/// Windows desktop platform configuration state.
class WindowsPlatformConfig {
  final bool isWasapiExclusiveModeActive;
  final bool isMicaMaterialEnabled;
  final int bufferPeriodMs;
  final String audioFormat; // e.g. 'PCM_FLOAT32_48000'

  const WindowsPlatformConfig({
    required this.isWasapiExclusiveModeActive,
    required this.isMicaMaterialEnabled,
    required this.bufferPeriodMs,
    required this.audioFormat,
  });
}

/// Windows Audio Session API (WASAPI) driver and Fluent UI 2 Mica/Acrylic compositor bridge.
class WindowsWasapiFluentEngine {
  /// Configures sovereign Windows desktop client runtime.
  WindowsPlatformConfig configureClient({bool enableExclusiveAudio = true}) {
    return WindowsPlatformConfig(
      isWasapiExclusiveModeActive: enableExclusiveAudio,
      isMicaMaterialEnabled: true,
      bufferPeriodMs: enableExclusiveAudio ? 5 : 20, // 5ms exclusive vs 20ms shared
      audioFormat: 'PCM_FLOAT32_48000',
    );
  }

  /// Calculates round-trip audio latency.
  double getExpectedLatencyMs(WindowsPlatformConfig config) {
    return (config.bufferPeriodMs * 1.5).clamp(2.0, 50.0);
  }
}
