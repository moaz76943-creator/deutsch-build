import 'package:test/test.dart';
import '../../lib/src/platform/linux_pipewire_tray_engine.dart';

void main() {
  group('LinuxPipewireTrayEngine Unit Tests (N081)', () {
    final engine = LinuxPipewireTrayEngine();

    test('Initializes with PipeWire backend achieving sub-10ms audio latency', () {
      final status = engine.initializeDaemon(preferPipeWire: true);
      expect(status.isPipeWireConnected, isTrue);
      expect(status.isSystemTrayVisible, isTrue);
      expect(status.activeAudioBackend, equals('PipeWire'));
      expect(status.activeAudioLatencyMs, lessThanOrEqualTo(8));
    });

    test('Generates valid libnotify command string for vocabulary reminders', () {
      final cmd = engine.generateDesktopNotification(reviewWord: 'Verbindung', definition: 'Connection / Union');
      expect(cmd, contains('notify-send'));
      expect(cmd, contains('Polyglot'));
      expect(cmd, contains('Verbindung: Connection / Union'));
    });

    test('Terminates daemon cleanly', () {
      engine.initializeDaemon();
      engine.terminate();
    });
  });
}
