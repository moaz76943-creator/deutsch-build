import 'package:test/test.dart';
import 'package:deutsch_build/src/core/platform/desktop_multiplatform_engine.dart';

void main() {
  group('DesktopMultiplatformEngine Tests', () {
    const engine = DesktopMultiplatformEngine();

    test('Resolves XDG compliant storage path for Linux and AppData for Windows', () {
      final linuxPath = engine.resolveStoragePath(DesktopOsType.linux, homeDir: '/home/developer');
      final macPath = engine.resolveStoragePath(DesktopOsType.macos, homeDir: '/Users/developer');
      final winPath = engine.resolveStoragePath(DesktopOsType.windows);

      expect(linuxPath, equals('/home/developer/.local/share/polyglot_sovereign'));
      expect(macPath, contains('Library/Application Support'));
      expect(winPath, contains('AppData\\Roaming'));
    });

    test('Maps desktop keyboard hotkeys accurately for fast learning sessions', () {
      expect(engine.handleKeyboardShortcut('space'), equals('ACTION_FLIP_FLASHCARD'));
      expect(engine.handleKeyboardShortcut('3'), equals('ACTION_FSRS_GOOD'));
      expect(engine.handleKeyboardShortcut('enter', isControlPressed: true), equals('ACTION_SUBMIT_DIALOGUE_TURN'));
      expect(engine.handleKeyboardShortcut('x'), equals('ACTION_NONE'));
    });

    test('Builds clean desktop notification payload without external cloud servers', () {
      final payload = engine.buildLocalNotificationPayload(
        title: 'Tägliche Wiederholung',
        body: '12 Vokabeln warten auf dich!',
        os: DesktopOsType.linux,
      );

      expect(payload['title'], equals('Tägliche Wiederholung'));
      expect(payload['appId'], equals('com.deutsch.polyglot'));
      expect(payload['urgency'], equals('normal'));
    });
  });
}
