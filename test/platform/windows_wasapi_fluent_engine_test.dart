import 'package:test/test.dart';
import '../../lib/src/platform/windows_wasapi_fluent_engine.dart';

void main() {
  group('WindowsWasapiFluentEngine Unit Tests (N084)', () {
    final engine = WindowsWasapiFluentEngine();

    test('Configures WASAPI exclusive mode with ultra-low 5ms buffer period', () {
      final config = engine.configureClient(enableExclusiveAudio: true);
      expect(config.isWasapiExclusiveModeActive, isTrue);
      expect(config.isMicaMaterialEnabled, isTrue);
      expect(config.bufferPeriodMs, equals(5));

      final latency = engine.getExpectedLatencyMs(config);
      expect(latency, closeTo(7.5, 0.1));
    });

    test('Shared mode maintains fallback 20ms buffer period', () {
      final config = engine.configureClient(enableExclusiveAudio: false);
      expect(config.isWasapiExclusiveModeActive, isFalse);
      expect(config.bufferPeriodMs, equals(20));
      expect(engine.getExpectedLatencyMs(config), equals(30.0));
    });
  });
}
