import 'package:test/test.dart';
import 'package:deutsch_build/src/core/theme/oled_cognitive_theme_engine.dart';

void main() {
  group('OledCognitiveThemeEngine Tests', () {
    const engine = OledCognitiveThemeEngine();

    test('Pure black background delivers true #000000 for OLED zero power consumption', () {
      final palette = engine.buildTheme(pureBlackOled: true);
      expect(palette.background.toHex(), equals('#000000'));
      expect(palette.background.r, equals(0));
      expect(palette.background.g, equals(0));
      expect(palette.background.b, equals(0));
      expect(palette.isPureBlackOled, isTrue);
    });

    test('Calculated contrast strictly exceeds WCAG AAA 7:1 ratio', () {
      final palette = engine.buildTheme(pureBlackOled: true, warmNightShift: true);
      expect(palette.calculatedContrast, greaterThanOrEqualTo(7.0));
      // Pure black vs warm amber text delivers over 15:1 contrast
      expect(palette.calculatedContrast, greaterThan(15.0));
    });

    test('Palette serializes correctly into UI config payload', () {
      final palette = engine.buildTheme();
      final json = palette.toJson();

      expect(json['background'], equals('#000000'));
      expect(json['isPureBlackOled'], isTrue);
      expect(json.containsKey('calculatedContrast'), isTrue);
    });
  });
}
