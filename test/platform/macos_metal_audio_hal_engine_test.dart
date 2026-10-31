import 'package:test/test.dart';
import '../../lib/src/platform/macos_metal_audio_hal_engine.dart';

void main() {
  group('MacOsMetalAudioHalEngine Unit Tests (N083)', () {
    final engine = MacOsMetalAudioHalEngine();

    test('Configures Metal acceleration and 120Hz ProMotion display profile', () {
      final config = engine.configureRuntime(enableProMotion120Hz: true);
      expect(config.isMetalRenderAccelerationEnabled, isTrue);
      expect(config.isCoreAudioHalDirectIpcActive, isTrue);
      expect(config.renderFrameRateHz, equals(120.0));
      expect(config.audioBufferSizeFrames, equals(128));
    });

    test('Calculates low-latency CoreAudio buffer duration (< 3ms)', () {
      final latency = engine.computeLatencyMs(128, 48000);
      expect(latency, closeTo(2.66, 0.05));
    });

    test('Zero sample rate handles safely', () {
      expect(engine.computeLatencyMs(128, 0), equals(0.0));
    });
  });
}
